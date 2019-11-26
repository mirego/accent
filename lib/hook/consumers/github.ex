defmodule Accent.Hook.Consumers.GitHub do
  @moduledoc """
  From a project’s integration association and a webhook event from GitHub,
  sync and add translation as if the operations were made manually by a user.

  """
  use Accent.Hook.EventConsumer, subscribe_to: [Accent.Hook.Producers.GitHub]

  alias Accent.{Document, Repo, Version}
  alias Accent.Hook.Consumers.GitHub.AddTranslations
  alias Accent.Hook.Consumers.GitHub.Sync
  alias Accent.Hook.Context
  alias Accent.Plugs.MovementContextParser
  alias Accent.Scopes.Document, as: DocumentScope
  alias Accent.Scopes.Version, as: VersionScope

  def handle_events(events, _from, state) do
    Enum.each(events, &handle_event/1)

    {:noreply, [], state}
  end

  defp handle_event(%Context{user: user, project: project, payload: payload}) do
    payload[:ref]
    |> ref_to_version(payload[:default_ref], project)
    |> sync_and_add_translations(project, user, payload)
  end

  defp sync_and_add_translations({:ok, version}, project, user, payload) do
    repo = payload[:repository]
    token = payload[:token]

    ref = (version && version.tag) || payload[:default_ref]
    configs = fetch_config(repo, token, ref)
    trees = fetch_trees(repo, token, ref)

    revisions =
      project
      |> Ecto.assoc(:target_revisions)
      |> Repo.all()
      |> Repo.preload(:language)

    Sync.persist(trees, configs, project, user, payload, version)

    Enum.each(revisions, fn revision ->
      AddTranslations.persist(trees, configs, project, user, revision, payload, version)
    end)
  end

  defp sync_and_add_translations(_, _, _, _), do: :ok

  def filter_by_patterns(patterns, files) do
    Enum.group_by(files, fn file -> Enum.find(patterns, &ExMinimatch.match(&1["matcher"], file["path"])) end)
  end

  def movement_document(project, path) do
    path =
      path
      |> Path.basename()
      |> MovementContextParser.extract_path_from_filename()

    Document
    |> DocumentScope.from_path(path)
    |> DocumentScope.from_project(project.id)
    |> Repo.one()
    |> Kernel.||(%Document{project_id: project.id, path: path})
  end

  def fetch_content(path, token) do
    with {:ok, %{body: %{"content" => content}}} <- file_server().get_path(path, headers(token)),
         decoded_contents <-
           content
           |> String.split("\n")
           |> Enum.reject(&(&1 === ""))
           |> Enum.map(&Base.decode64/1),
         true <- Enum.all?(decoded_contents, &match?({:ok, _}, &1)),
         decoded_content <-
           decoded_contents
           |> Enum.map(&elem(&1, 1))
           |> Enum.join("") do
      {:ok, decoded_content}
    else
      _ -> {:ok, nil}
    end
  end

  def ref_to_version(ref, default_ref, project) do
    default_version(ref, default_ref) || version_from_ref(ref, project)
  end

  defp default_version(ref, default_ref) do
    case Regex.named_captures(~r/refs\/heads\/(?<branch>.+)/, ref) do
      %{"branch" => ^default_ref} -> {:ok, nil}
      _ -> nil
    end
  end

  defp version_from_ref(ref, project) do
    with %{"tag" => tag} <- Regex.named_captures(~r/refs\/tags\/(?<tag>.+)/, ref),
         version = %Version{} <-
           Version
           |> VersionScope.from_project(project.id)
           |> VersionScope.from_tag(tag)
           |> Repo.one() do
      {:ok, version}
    else
      _ ->
        nil
    end
  end

  defp fetch_config(repo, token, ref) do
    with path <- Path.join([repo, "contents", "accent.json"]) <> "?ref=#{ref}",
         {:ok, config} when is_binary(config) <- fetch_content(path, token),
         {:ok, %{"files" => files}} <- Jason.decode(config) do
      files
    else
      _ -> []
    end
  end

  defp fetch_trees(repo, token, ref) do
    with path <- Path.join([repo, "git", "trees", ref]) <> "?recursive=1",
         {:ok, %{body: %{"tree" => tree}}} <- file_server().get_path(path, headers(token)) do
      filter_blob_file_only(tree)
    else
      _ -> []
    end
  end

  defp filter_blob_file_only(files) do
    Enum.filter(files, &(&1["type"] === "blob"))
  end

  defp headers(token) do
    [{"Authorization", "token #{token}"}]
  end

  defp file_server, do: Application.get_env(:accent, :hook_github_file_server)
end
