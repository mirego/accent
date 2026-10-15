defmodule Movement.Builders.RevisionCorrectAll do
  @moduledoc false
  @behaviour Movement.Builder

  import Ecto.Query

  alias Accent.Repo
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.Translation
  alias Movement.Builders.CorrectedTextOperations

  def build(%Movement.Context{assigns: assigns} = context) do
    translations =
      Translation
      |> TranslationScope.active()
      |> TranslationScope.not_locked()
      |> TranslationScope.conflicted()
      |> TranslationScope.from_revision(assigns[:revision].id)
      |> TranslationScope.from_version(assigns[:version_id])
      |> TranslationScope.from_document(assigns[:document_id] || :all)
      |> filter_by_from_version(assigns[:from_version_id], assigns[:revision].id)
      |> Repo.all()

    CorrectedTextOperations.build(context, translations, "correct_conflict")
  end

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
