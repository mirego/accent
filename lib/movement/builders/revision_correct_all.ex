defmodule Movement.Builders.RevisionCorrectAll do
  @moduledoc false
  @behaviour Movement.Builder

  import Ecto.Query
  import Movement.Context, only: [assign: 3]

  alias Accent.Repo
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.Translation
  alias Movement.Mappers.Operation, as: OperationMapper

  @action "correct_conflict"

  def build(context) do
    context
    |> assign_translations()
    |> process_operations()
  end

  defp process_operations(%Movement.Context{assigns: assigns, operations: operations} = context) do
    new_operations =
      Enum.map(assigns[:translations], fn translation ->
        OperationMapper.map(@action, translation, %{text: translation.corrected_text})
      end)

    %{context | operations: Enum.concat(operations, new_operations)}
  end

  defp assign_translations(%Movement.Context{assigns: assigns} = context) do
    translations =
      Translation
      |> TranslationScope.active()
      |> TranslationScope.not_locked()
      |> TranslationScope.conflicted()
      |> TranslationScope.from_revision(assigns[:revision].id)
      |> filter_by_version(assigns[:version_id])
      |> filter_by_document(assigns[:document_id])
      |> filter_by_from_version(assigns[:from_version_id], assigns[:revision].id)
      |> Repo.all()

    assign(context, :translations, translations)
  end

  defp filter_by_version(query, nil), do: TranslationScope.no_version(query)
  defp filter_by_version(query, version_id), do: TranslationScope.from_version(query, version_id)

  defp filter_by_document(query, nil), do: query
  defp filter_by_document(query, document_id), do: TranslationScope.from_document(query, document_id)

  defp filter_by_from_version(query, nil, _revision_id), do: query

  defp filter_by_from_version(query, from_version_id, revision_id) do
    source_ids =
      Translation
      |> TranslationScope.from_version(from_version_id)
      |> TranslationScope.from_revision(revision_id)
      |> TranslationScope.active()
      |> select([t], t.source_translation_id)

    from(t in query, where: t.id in subquery(source_ids))
  end
end
