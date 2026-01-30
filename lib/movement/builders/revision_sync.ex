defmodule Movement.Builders.RevisionSync do
  @moduledoc false
  @behaviour Movement.Builder

  import Ecto.Query
  import Movement.Context, only: [assign: 3]

  alias Accent.Repo
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.Translation
  alias Accent.Version
  alias Movement.EntriesCommitProcessor

  def build(context) do
    context
    |> assign_translations()
    |> assign_versioned_translations()
    |> EntriesCommitProcessor.process()
    |> EntriesCommitProcessor.process_for_remove()
  end

  defp assign_translations(context) do
    translations =
      Translation
      |> TranslationScope.from_revision(context.assigns[:revision].id)
      |> TranslationScope.from_document(context.assigns[:document].id)
      |> TranslationScope.from_version(context.assigns[:version] && context.assigns[:version].id)
      |> Repo.all()

    assign(context, :translations, translations)
  end

  defp assign_versioned_translations(%{assigns: %{version: version}} = context) when not is_nil(version) do
    assign(context, :versioned_translations_by_key, %{})
  end

  defp assign_versioned_translations(context) do
    project_id = context.assigns[:project].id
    document_id = context.assigns[:document].id
    revision_id = context.assigns[:revision].id

    latest_version =
      Version
      |> where(project_id: ^project_id)
      |> order_by(desc: :inserted_at)
      |> limit(1)
      |> Repo.one()

    versioned_translations_by_key =
      if latest_version do
        Translation
        |> where(version_id: ^latest_version.id)
        |> where(document_id: ^document_id)
        |> where(revision_id: ^revision_id)
        |> where([t], is_nil(t.source_translation_id))
        |> Repo.all()
        |> Enum.group_by(& &1.key)
      else
        %{}
      end

    assign(context, :versioned_translations_by_key, versioned_translations_by_key)
  end
end
