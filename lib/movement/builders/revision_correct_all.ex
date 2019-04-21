defmodule Movement.Builders.RevisionCorrectAll do
  @behaviour Movement.Builder

  import Movement.Context, only: [assign: 3]

  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.{Repo, Translation}
  alias Movement.Mappers.Operation, as: OperationMapper

  @action "correct_conflict"

  def build(context) do
    context
    |> assign_translations()
    |> process_operations()
  end

  defp process_operations(context = %Movement.Context{assigns: assigns, operations: operations}) do
    new_operations =
      Enum.map(assigns[:translations], fn translation ->
        OperationMapper.map(@action, translation, %{text: translation.corrected_text})
      end)

    %{context | operations: Enum.concat(operations, new_operations)}
  end

  defp assign_translations(context = %Movement.Context{assigns: assigns}) do
    translations =
      Translation
      |> TranslationScope.active()
      |> TranslationScope.not_locked()
      |> TranslationScope.conflicted()
      |> TranslationScope.from_revision(assigns[:revision].id)
      |> TranslationScope.no_version()
      |> Repo.all()

    assign(context, :translations, translations)
  end
end
