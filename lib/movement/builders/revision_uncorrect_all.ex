defmodule Movement.Builders.RevisionUncorrectAll do
  @moduledoc false
  @behaviour Movement.Builder

  alias Accent.Repo
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.Translation
  alias Movement.Builders.CorrectedTextOperations

  def build(%Movement.Context{assigns: assigns} = context) do
    translations =
      Translation
      |> TranslationScope.active()
      |> TranslationScope.not_locked()
      |> TranslationScope.not_conflicted()
      |> TranslationScope.from_revision(assigns[:revision].id)
      |> TranslationScope.from_version(assigns[:version_id])
      |> TranslationScope.from_document(assigns[:document_id] || :all)
      |> Repo.all()

    CorrectedTextOperations.build(context, translations, "uncorrect_conflict")
  end
end
