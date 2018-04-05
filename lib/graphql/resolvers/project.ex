defmodule Accent.GraphQL.Resolvers.Project do
  require Ecto.Query

  alias Accent.Scopes.Project, as: ProjectScope

  alias Accent.{
    Repo,
    Project,
    ProjectCreator,
    ProjectUpdater,
    ProjectDeleter,
    User,
    GraphQL.Paginated,
    Plugs.GraphQLContext
  }

  alias Ecto.Query

  @typep project_operation :: {:ok, %{project: Project.t() | nil, errors: [String.t()] | nil}}

  @spec create(any(), %{name: String.t(), language_id: String.t()}, GraphQLContext.t()) :: project_operation
  def create(_, %{name: name, language_id: language_id}, info) do
    params = %{
      "name" => name,
      "language_id" => language_id
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

  @spec update(Project.t(), %{name: String.t(), is_file_operations_locked: boolean() | nil}, GraphQLContext.t()) :: project_operation
  def update(project, %{name: name, is_file_operations_locked: locked_file_operations}, info) do
    params = %{
      "name" => name,
      "locked_file_operations" => locked_file_operations
    }

    case ProjectUpdater.update(project: project, params: params, user: info.context[:conn].assigns[:current_user]) do
      {:ok, project} ->
        {:ok, %{project: project, errors: nil}}

      {:error, _reason} ->
        {:ok, %{project: nil, errors: ["unprocessable_entity"]}}
    end
  end

  def update(project, %{name: name}, info), do: update(project, %{name: name, is_file_operations_locked: nil}, info)

  @spec list_viewer(User.t(), %{query: String.t(), page: number()}, GraphQLContext.t()) :: {:ok, Paginated.t(Project.t())}
  def list_viewer(viewer, args, _info) do
    Project
    |> Query.join(:inner, [p], c in assoc(p, :collaborators))
    |> Query.where([_, c], c.user_id == ^viewer.id)
    |> Query.order_by([p, _], asc: p.name)
    |> ProjectScope.from_search(args[:query])
    |> Repo.paginate(page: args[:page])
    |> Paginated.format()
    |> (&{:ok, &1}).()
  end

  @spec show_viewer(any(), %{id: String.t()}, GraphQLContext.t()) :: {:ok, Project.t() | nil}
  def show_viewer(_, %{id: id}, _) do
    Project
    |> Repo.get(id)
    |> (&{:ok, &1}).()
  end
end
