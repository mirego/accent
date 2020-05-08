defmodule Accent.Hook.Consumers.GitHub.Sync do
  alias Accent.Plugs.MovementContextParser
  alias Movement.Builders.ProjectSync, as: SyncBuilder
  alias Movement.Context
  alias Movement.Persisters.ProjectSync, as: SyncPersister

  alias Accent.Hook.Consumers.GitHub

  def persist(trees, configs, project, user, payload, version) do
    token = payload[:token]

    trees
    |> group_by_matched_source_config(configs)
    |> Enum.reject(&(elem(&1, 0) === nil))
    |> Enum.flat_map(fn {config, files} ->
      Enum.map(files, &build_context(&1, project, token, config["format"]))
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&assign_defaults(&1, user, project, version))
    |> Enum.each(&persist_contexts/1)
  end

  defp group_by_matched_source_config(files, configs) do
    configs
    |> Enum.map(&Map.put(&1, "matcher", ExMinimatch.compile(&1["source"])))
    |> GitHub.filter_by_patterns(files)
  end

  defp persist_contexts(context) do
    context
    |> SyncBuilder.build()
    |> SyncPersister.persist()
  end

  defp assign_defaults(context, user, project, version) do
    context
    |> Context.assign(:user_id, user.id)
    |> Context.assign(:project, project)
    |> Context.assign(:version, version)
    |> Context.assign(:comparer, Movement.Comparer.comparer(:sync, "smart"))
  end

  defp build_context(file, project, token, format) do
    with {:ok, parser} <- Langue.parser_from_format(format),
         document <- GitHub.movement_document(project, file["path"]),
         document <- %{document | format: format},
         {:ok, file_content} <- GitHub.fetch_content(file["url"], token),
         %{entries: entries, document: parsed_document} <- MovementContextParser.to_entries(document, file_content, parser) do
      %Context{
        render: file_content,
        entries: entries,
        assigns: %{
          document: document,
          document_update: document_update(parsed_document)
        }
      }
    else
      _ -> nil
    end
  end

  defp document_update(nil), do: nil

  defp document_update(parsed_document) do
    %{top_of_the_file_comment: parsed_document.top_of_the_file_comment, header: parsed_document.header}
  end
end
