defmodule Accent.GraphQL.Resolvers.MachineTranslation do
  @moduledoc false
  alias Accent.Language
  alias Accent.MachineTranslations
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Scopes.Revision, as: RevisionScope
  alias Ecto.Query

  require Ecto.Query

  @spec translate_text(
          Project.t(),
          %{text: String.t(), source_language_slug: String.t() | nil, target_language_slug: String.t()},
          GraphQLContext.t()
        ) :: {:ok, %{error: nil | binary(), provider: atom(), text: binary()}}
  def translate_text(project, args, _info) do
    source_language = args[:source_language_slug] && slug_language(project.id, args.source_language_slug)
    target_language = slug_language(project.id, args.target_language_slug)

    result = %{
      text: nil,
      error: nil,
      provider: MachineTranslations.id_from_config(project.machine_translations_config)
    }

    result =
      case MachineTranslations.translate(
             [%{value: args.text}],
             source_language && source_language.slug,
             target_language.slug,
             project.machine_translations_config
           ) do
        [%{value: text}] -> %{result | text: text}
        {:error, error} when is_atom(error) -> %{result | error: to_string(error)}
        _ -> result
      end

    {:ok, result}
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
