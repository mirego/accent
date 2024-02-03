defmodule Movement.Builders.NewSlave do
  @moduledoc false
  @behaviour Movement.Builder

  import Movement.Context, only: [assign: 3]

  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Scopes.Revision, as: RevisionScope
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.Translation
  alias Movement.Mappers.Operation, as: OperationMapper

  @action "new"

  def build(context) do
    context
    |> assign_master_revision()
    |> assign_translations()
    |> process_operations()
  end

  defp process_operations(%Movement.Context{assigns: assigns, operations: operations} = context) do
    default_null = "default_null" in assigns.new_slave_options
    machine_translations_enabled = "machine_translations_enabled" in assigns.new_slave_options

    new_operations =
      Enum.map(assigns[:translations], fn translation ->
        OperationMapper.map(@action, translation, %{
          key: translation.key,
          text: if(default_null, do: "", else: translation.corrected_text),
          file_comment: translation.file_comment,
          file_index: translation.file_index,
          document_id: translation.document_id,
          version_id: translation.version_id,
          value_type: translation.value_type,
          plural: translation.plural,
          locked: translation.locked,
          placeholders: translation.placeholders,
          translation_id: translation.id,
          options: assigns.new_slave_options,
          machine_translations_enabled: machine_translations_enabled
        })
      end)

    new_operations =
      if machine_translations_enabled do
        Movement.MachineTranslations.translate(
          new_operations,
          assigns[:project],
          assigns[:master_revision],
          assigns[:language]
        )
      else
        new_operations
      end

    %{context | operations: Enum.concat(operations, new_operations)}
  end

  defp assign_translations(%Movement.Context{assigns: assigns} = context) do
    translations =
      Translation
      |> TranslationScope.from_revision(assigns[:master_revision].id)
      |> TranslationScope.no_version()
      |> Repo.all()

    assign(context, :translations, translations)
  end

  defp assign_master_revision(%Movement.Context{assigns: assigns} = context) do
    master_revision =
      Revision
      |> RevisionScope.from_project(assigns[:project].id)
      |> RevisionScope.master()
      |> Repo.one!()
      |> Repo.preload(:language)

    assign(context, :master_revision, master_revision)
  end
end
