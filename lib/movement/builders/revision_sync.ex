defmodule Movement.Builders.RevisionSync do
  @behaviour Movement.Builder

  import Movement.Context, only: [assign: 3]

  alias Movement.EntriesCommitProcessor
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.Repo
  alias Accent.Translation

  def build(context) do
    context
    |> assign_translations()
    |> EntriesCommitProcessor.process()
    |> EntriesCommitProcessor.process_for_remove()
  end

  defp assign_translations(context) do
    translations =
      Translation
      |> TranslationScope.from_revision(context.assigns[:revision].id)
      |> TranslationScope.from_document(context.assigns[:document].id)
      |> Repo.all()

    assign(context, :translations, translations)
  end
end
