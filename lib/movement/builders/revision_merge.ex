defmodule Movement.Builders.RevisionMerge do
  @moduledoc false
  @behaviour Movement.Builder

  import Movement.Context, only: [assign: 3]

  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Scopes.Revision, as: RevisionScope
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.Translation
  alias Movement.EntriesCommitProcessor

  @batch_action "merge"

  def build(context) do
    context
    |> assign_translations()
    |> assign_master_revision()
    |> Movement.Context.assign(:batch_action, @batch_action)
    |> EntriesCommitProcessor.process()
  end

  defp assign_master_revision(context) do
    master_revision =
      Revision
      |> RevisionScope.from_project(context.assigns[:project].id)
      |> RevisionScope.master()
      |> Repo.one!()
      |> Repo.preload(:language)

    assign(context, :master_revision, master_revision)
  end

  defp assign_translations(context) do
    translations =
      Translation
      |> TranslationScope.active()
      |> TranslationScope.from_revision(context.assigns[:revision].id)
      |> TranslationScope.from_document(context.assigns[:document].id)
      |> TranslationScope.from_version(context.assigns[:version] && context.assigns[:version].id)
      |> Repo.all()

    assign(context, :translations, translations)
  end
end
