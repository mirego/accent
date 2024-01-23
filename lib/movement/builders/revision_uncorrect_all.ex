defmodule Movement.Builders.RevisionUncorrectAll do
  @moduledoc false
  @behaviour Movement.Builder

  import Movement.Context, only: [assign: 3]

  alias Accent.Repo
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.Translation
  alias Movement.Mappers.Operation, as: OperationMapper

  @action "uncorrect_conflict"

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
      |> TranslationScope.not_conflicted()
      |> TranslationScope.from_revision(assigns[:revision].id)
      |> TranslationScope.no_version()
      |> Repo.all()

    assign(context, :translations, translations)
  end
end
