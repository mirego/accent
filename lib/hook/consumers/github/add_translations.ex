defmodule Accent.Hook.Consumers.GitHub.AddTranslations do
  alias Accent.Plugs.MovementContextParser
  alias Movement.Builders.RevisionMerge, as: RevisionMergeBuilder
  alias Movement.Context
  alias Movement.Persisters.RevisionMerge, as: RevisionMergePersister

  alias Accent.Hook.Consumers.GitHub

  def persist(trees, configs, project, user, revision, payload, version) do
    token = payload[:token]

    trees
    |> group_by_matched_target_config(configs, revision)
    |> Enum.reject(&(elem(&1, 0) === nil))
    |> Enum.flat_map(fn {config, files} ->
      Enum.map(files, &build_context(&1, project, token, config["format"]))
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&assign_defaults(&1, user, revision, project, version))
    |> Enum.each(&persist_contexts/1)
  end

  defp group_by_matched_target_config(files, configs, revision) do
    configs
    |> Enum.map(fn config ->
      target =
        config["target"]
        |> Kernel.||("")
        |> String.replace("%slug%", Accent.Revision.language(revision).slug)
        |> String.replace("%original_file_name%", "*")
        |> String.replace("%document_path%", "*")

      Map.put(config, "matcher", ExMinimatch.compile(target))
    end)
    |> GitHub.filter_by_patterns(files)
  end

  defp persist_contexts(context) do
    context
    |> RevisionMergeBuilder.build()
    |> RevisionMergePersister.persist()
  end

  defp assign_defaults(context, user, revision, project, version) do
    context
    |> Context.assign(:user_id, user.id)
    |> Context.assign(:revision, revision)
    |> Context.assign(:project, project)
    |> Context.assign(:version, version)
    |> Context.assign(:merge_type, "smart")
    |> Context.assign(:comparer, Movement.Comparer.comparer(:merge, "smart"))
  end

  defp build_context(file, project, token, format) do
    with {:ok, parser} <- Langue.parser_from_format(format),
         document = %{id: id} when not is_nil(id) <- GitHub.movement_document(project, file["path"]),
         document <- %{document | format: format},
         {:ok, file_content} <- GitHub.fetch_content(file["url"], token),
         %{entries: entries} <- MovementContextParser.to_entries(document, file_content, parser) do
      %Context{
        render: file_content,
        entries: entries,
        assigns: %{
          document: document,
          document_update: %{}
        }
      }
    else
      _ -> nil
    end
  end
end
