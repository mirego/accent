defmodule Accent.GraphQL.Resolvers.Project do
  require Ecto.Query

  alias Accent.Scopes.Project, as: ProjectScope

  alias Accent.{
    GraphQL.Paginated,
    Operation,
    Plugs.GraphQLContext,
    Project,
    ProjectCreator,
    ProjectDeleter,
    ProjectUpdater,
    Repo,
    User
  }

  alias Ecto.Query

  @typep project_operation :: {:ok, %{project: Project.t() | nil, errors: [String.t()] | nil}}

  @spec create(any(), %{name: String.t(), language_id: String.t()}, GraphQLContext.t()) :: project_operation
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

  @spec update(Project.t(), %{name: String.t(), main_color: String.t()}, GraphQLContext.t()) :: project_operation
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

    case ProjectUpdater.update(project: project, params: params, user: info.context[:conn].assigns[:current_user]) do
      {:ok, project} ->
        {:ok, %{project: project, errors: nil}}

      {:error, _reason} ->
        {:ok, %{project: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec list_viewer(User.t(), %{query: String.t(), page: number()}, GraphQLContext.t()) :: {:ok, Paginated.t(Project.t())}
  def list_viewer(viewer, args, _info) do
    Project
    |> Query.join(:inner, [p], c in assoc(p, :collaborators))
    |> Query.where([_, c], c.user_id == ^viewer.id)
    |> Query.order_by([p, _], asc: p.name)
    |> ProjectScope.from_search(args[:query])
    |> ProjectScope.with_stats()
    |> Paginated.paginate(args)
    |> Paginated.format()
    |> (&{:ok, &1}).()
  end

  @spec show_viewer(any(), %{id: String.t()}, GraphQLContext.t()) :: {:ok, Project.t() | nil}
  def show_viewer(_, %{id: id}, _) do
    Project
    |> ProjectScope.with_stats()
    |> Repo.get(id)
    |> (&{:ok, &1}).()
  end

  @spec last_activity(Project.t(), any(), GraphQLContext.t()) :: {:ok, Operation.t() | nil}
  def last_activity(project, _, _) do
    Operation
    |> Query.join(:left, [o], r in assoc(o, :revision))
    |> Query.where([o, r], r.project_id == ^project.id or o.project_id == ^project.id)
    |> Query.order_by([o], desc: o.inserted_at)
    |> Query.limit(1)
    |> Repo.one()
    |> (&{:ok, &1}).()
  end
end
