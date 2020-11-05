defmodule Accent.GraphQL.Resolvers.MachineTranslation do
  require Ecto.Query
  alias Ecto.Query

  alias Accent.Scopes.Revision, as: RevisionScope

  alias Accent.{
    Language,
    MachineTranslations,
    Project,
    Repo,
    Revision
  }

  @spec translate_text(Project.t(), %{text: String.t(), source_language_slug: String.t(), target_language_slug: String.t()}, GraphQLContext.t()) :: nil
  def translate_text(project, args, _info) do
    source_language = slug_language(project.id, args.source_language_slug)
    target_language = slug_language(project.id, args.target_language_slug)

    {:ok, MachineTranslations.translate_text(args.text, source_language, target_language)}
  end

  defp slug_language(project_id, slug) do
    revision =
      Revision
      |> RevisionScope.from_project(project_id)
      |> Query.where(slug: ^slug)
      |> Repo.one()

    language = Repo.get_by(Language, slug: slug)

    revision || language
  end
end
