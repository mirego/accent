defmodule Movement.Builders.SlaveConflictSync do
  @moduledoc false
  @behaviour Movement.Builder

  import Movement.Context, only: [assign: 3]

  alias Accent.Repo
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.Translation
  alias Movement.Mappers.Operation, as: OperationMapper

  @included_actions ~w(conflict_on_corrected conflict_on_proposed)
  @action "conflict_on_slave"

  def build(%Movement.Context{} = context) do
    context
    |> assign_revision_ids()
    |> assign_operation_keys()
    |> assign_translations()
    |> process_operations()
  end

  defp process_operations(%Movement.Context{assigns: assigns} = context) do
    new_operations =
      Enum.map(assigns[:translations], fn translation ->
        OperationMapper.map(@action, translation, %{
          text: translation.corrected_text,
          key: translation.key,
          file_comment: translation.file_comment,
          file_index: translation.file_index
        })
      end)

    %{context | operations: Enum.concat(context.operations, new_operations)}
  end

  defp assign_translations(%Movement.Context{assigns: assigns} = context) do
    translations =
      Translation
      |> TranslationScope.active()
      |> TranslationScope.not_locked()
      |> TranslationScope.from_revisions(assigns[:revision_ids])
      |> TranslationScope.from_keys(assigns[:translation_keys])
      |> TranslationScope.from_version(assigns[:version] && assigns[:version].id)
      |> then(fn query ->
        if assigns[:document] && assigns[:document].id do
          TranslationScope.from_document(query, assigns.document.id)
        else
          query
        end
      end)
      |> Repo.all()
      |> Repo.preload(:revision)

    assign(context, :translations, translations)
  end

  defp assign_revision_ids(%Movement.Context{assigns: assigns} = context) do
    assign(context, :revision_ids, Enum.map(assigns[:revisions], &Map.get(&1, :id)))
  end

  defp assign_operation_keys(%Movement.Context{operations: operations} = context) do
    keys =
      operations
      |> Enum.filter(fn %{action: action} -> action in @included_actions end)
      |> Enum.map(&Map.get(&1, :key))

    assign(context, :translation_keys, keys)
  end
end
