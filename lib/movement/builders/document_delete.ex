defmodule Movement.Builders.DocumentDelete do
  @behaviour Movement.Builder

  import Movement.Context, only: [assign: 3]

  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.{Project, Repo, Translation}
  alias Movement.Mappers.Operation, as: OperationMapper

  @action "remove"

  def build(context) do
    context
    |> assign_translations()
    |> assign_project()
    |> process_operations()
  end

  defp assign_translations(context) do
    translations =
      Translation
      |> TranslationScope.active()
      |> TranslationScope.from_document(context.assigns[:document].id)
      |> Repo.all()

    assign(context, :translations, translations)
  end

  defp assign_project(context) do
    project = Repo.get(Project, context.assigns[:document].project_id)

    assign(context, :project, project)
  end

  defp process_operations(context = %Movement.Context{assigns: %{translations: translations}, operations: operations}) do
    new_operations =
      Enum.map(translations, fn translation ->
        OperationMapper.map(@action, translation, %{translation | marked_as_removed: true})
      end)

    %{context | operations: Enum.concat(operations, new_operations)}
  end
end
