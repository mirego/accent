defmodule Movement.Builders.NewSlave do
  @behaviour Movement.Builder

  import Movement.Context, only: [assign: 3]

  alias Accent.Scopes.Revision, as: RevisionScope
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.{Repo, Revision, Translation}
  alias Movement.Mappers.Operation, as: OperationMapper

  @action "new"

  def build(context) do
    context
    |> assign_master_revision()
    |> assign_translations()
    |> process_operations()
  end

  defp process_operations(context = %Movement.Context{assigns: assigns, operations: operations}) do
    new_operations =
      Enum.map(assigns[:translations], fn translation ->
        OperationMapper.map(@action, translation, %{
          key: translation.key,
          text: translation.corrected_text,
          file_comment: translation.file_comment,
          file_index: translation.file_index,
          document_id: translation.document_id,
          version_id: translation.version_id,
          value_type: translation.value_type,
          plural: translation.plural,
          locked: translation.locked,
          placeholders: translation.placeholders
        })
      end)

    %{context | operations: Enum.concat(operations, new_operations)}
  end

  defp assign_translations(context = %Movement.Context{assigns: assigns}) do
    translations =
      Translation
      |> TranslationScope.from_revision(assigns[:master_revision].id)
      |> TranslationScope.no_version()
      |> Repo.all()

    assign(context, :translations, translations)
  end

  defp assign_master_revision(context = %Movement.Context{assigns: assigns}) do
    master_revision =
      Revision
      |> RevisionScope.from_project(assigns[:project].id)
      |> RevisionScope.master()
      |> Repo.one!()

    assign(context, :master_revision, master_revision)
  end
end
