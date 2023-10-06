defmodule Accent.GraphQL.Resolvers.Project do
  @moduledoc false
  alias Accent.GraphQL.Paginated
  alias Accent.Operation
  alias Accent.Plugs.GraphQLContext
  alias Accent.Project
  alias Accent.ProjectCreator
  alias Accent.ProjectDeleter
  alias Accent.ProjectUpdater
  alias Accent.Repo
  alias Accent.Scopes.Operation, as: OperationScope
  alias Accent.Scopes.Project, as: ProjectScope
  alias Accent.Scopes.Revision, as: RevisionScope
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.Translation
  alias Accent.User
  alias Ecto.Query

  require Ecto.Query

  @typep project_operation :: {:ok, %{project: Project.t() | nil, errors: [String.t()] | nil}}

  @spec create(any(), %{name: String.t(), language_id: String.t()}, GraphQLContext.t()) ::
          project_operation
  def create(_, args, info) do
    params = %{
      "name" => args.name,
      "main_color" => args.main_color,
      "logo" => args.logo,
      "language_id" => args.language_id
    }

    case ProjectCreator.create(params: params, user: info.context[:conn].assigns[:current_user]) do
      {:ok, project} ->
        {:ok, %{project: project, errors: nil}}

      {:error, _reason} ->
        {:ok, %{project: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec delete(Project.t(), any(), GraphQLContext.t()) :: project_operation
  def delete(project, _, _) do
    {:ok, _} = ProjectDeleter.delete(project: project)

    {:ok, %{project: project, errors: nil}}
  end

  @spec update(Project.t(), %{name: String.t(), main_color: String.t()}, GraphQLContext.t()) ::
          project_operation
  def update(project, args, info) do
    args =
      Map.merge(
        %{
          is_file_operations_locked: nil,
          logo: nil
        },
        args
      )

    params = %{
      "name" => args.name,
      "main_color" => args.main_color,
      "logo" => args.logo,
      "locked_file_operations" => args.is_file_operations_locked
    }

    case ProjectUpdater.update(
           project: project,
           params: params,
           user: info.context[:conn].assigns[:current_user]
         ) do
      {:ok, project} ->
        {:ok, %{project: project, errors: nil}}

      {:error, _reason} ->
        {:ok, %{project: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec list_viewer(User.t(), %{query: String.t(), page: number()}, GraphQLContext.t()) ::
          {:ok, Paginated.t(Project.t())}
  def list_viewer(viewer, args, _info) do
    paginated_projects =
      Project
      |> Query.join(:inner, [p], c in assoc(p, :collaborators))
      |> Query.where([_, c], c.user_id == ^viewer.id)
      |> Query.order_by([p, _], asc: p.name)
      |> ProjectScope.from_search(args[:query])
      |> ProjectScope.with_stats()
      |> Paginated.paginate(args)
      |> Paginated.format()

    nodes_projects =
      Project
      |> Query.join(:inner, [p], c in assoc(p, :collaborators))
      |> Query.where([_, c], c.user_id == ^viewer.id)
      |> ProjectScope.from_ids(args[:node_ids])
      |> ProjectScope.with_stats()
      |> Repo.all()

    projects = Map.put(paginated_projects, :nodes, nodes_projects)

    {:ok, projects}
  end

  @spec show_viewer(any(), %{id: String.t()}, GraphQLContext.t()) :: {:ok, Project.t() | nil}
  def show_viewer(_, %{id: id}, _) do
    Project
    |> ProjectScope.with_stats()
    |> Repo.get(id)
    |> then(&{:ok, &1})
  end

  @spec last_activity(Project.t(), any(), GraphQLContext.t()) :: {:ok, Operation.t() | nil}
  def last_activity(project, args, _) do
    Operation
    |> OperationScope.filter_from_project(project.id)
    |> OperationScope.filter_from_action(args[:action])
    |> OperationScope.order_last_to_first()
    |> Query.limit(1)
    |> Repo.one()
    |> then(&{:ok, &1})
  end

  @spec lint_translations(Project.t(), any(), GraphQLContext.t()) ::
          {:ok, [Accent.TranslationLint.t()]}
  def lint_translations(project, args, _) do
    translations =
      Translation
      |> TranslationScope.from_project(project.id)
      |> TranslationScope.from_revision(args.revision_id || :all)
      |> TranslationScope.from_version(nil)
      |> TranslationScope.from_search(args.query)
      |> TranslationScope.active()
      |> TranslationScope.not_locked()
      |> Query.distinct(true)
      |> Query.preload([:document, [revision: :language]])
      |> Query.order_by({:asc, :key})
      |> Repo.all()

    master_revision =
      project
      |> Ecto.assoc(:revisions)
      |> RevisionScope.master()
      |> Repo.one()

    master_translations =
      Translation
      |> TranslationScope.from_project(project.id)
      |> TranslationScope.from_revision(master_revision.id)
      |> TranslationScope.from_version(nil)
      |> TranslationScope.active()
      |> TranslationScope.not_locked()
      |> Repo.all()
      |> Map.new(&{{&1.key, &1.document_id}, &1})

    entries =
      Enum.map(translations, fn translation ->
        master_translation =
          Map.get(master_translations, {translation.key, translation.document_id})

        language_slug = translation.revision.slug || translation.revision.language.slug

        Translation.to_langue_entry(
          translation,
          master_translation,
          translation.revision.master,
          language_slug
        )
      end)

    translations =
      entries
      |> Accent.Lint.lint(%Accent.Lint.Config{enabled_rule_ids: args.rule_ids})
      |> Enum.filter(&Enum.any?(elem(&1, 1)))
      |> Enum.map(fn {entry, messages} ->
        %Accent.TranslationLint{id: entry.id, translation_id: entry.id, messages: messages}
      end)

    {:ok, translations}
  end
end
