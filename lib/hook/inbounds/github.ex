defmodule Accent.Hook.Inbounds.GitHub do
  @moduledoc false
  use Oban.Worker, queue: :hook

  alias Accent.Document
  alias Accent.Hook.Inbounds.GitHub.AddTranslations
  alias Accent.Hook.Inbounds.GitHub.Sync
  alias Accent.Plugs.MovementContextParser
  alias Accent.Repo
  alias Accent.Scopes.Document, as: DocumentScope
  alias Accent.Scopes.Version, as: VersionScope
  alias Accent.Version

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    context = Accent.Hook.Context.from_worker(args)

    context.payload["ref"]
    |> ref_to_version(context.payload["default_ref"], context.project)
    |> sync_and_add_translations(context.project, context.user, context.payload)
  end

  defp sync_and_add_translations({:ok, version}, project, user, payload) do
    repo = payload["repository"]
    token = payload["token"]

    ref = (version && version.tag) || payload["default_ref"]
    configs = fetch_config(repo, token, ref)
    trees = fetch_trees(repo, token, ref)

    revisions =
      project
      |> Ecto.assoc(:target_revisions)
      |> Repo.all()
      |> Repo.preload(:language)

    Sync.persist(trees, configs, project, user, token, version)

    Enum.each(revisions, fn revision ->
      AddTranslations.persist(trees, configs, project, user, revision, token, version)
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
         decoded_content <- Enum.map_join(decoded_contents, "", &elem(&1, 1)) do
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
         %Version{} = version <-
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
      Enum.filter(tree, &(&1["type"] === "blob"))
    else
      _ -> []
    end
  end

  defp headers(token) do
    [{"Authorization", "token #{token}"}]
  end

  defp file_server, do: Application.get_env(:accent, :hook_github_file_server)
end
