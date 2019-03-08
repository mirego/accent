defmodule Accent.GraphQL.Resolvers.Activity do
  require Ecto.Query
  alias Ecto.Query

  alias Accent.Scopes.Operation, as: OperationScope

  alias Accent.{
    GraphQL.Paginated,
    Operation,
    Plugs.GraphQLContext,
    Project,
    Repo,
    Translation
  }

  @spec list_project(Project.t(), map(), GraphQLContext.t()) :: {:ok, Paginated.t(Operation.t())}
  def list_project(project, args, _) do
    Operation
    |> OperationScope.ignore_actions(args[:action], args[:is_batch])
    |> OperationScope.filter_from_user(args[:user_id])
    |> OperationScope.filter_from_batch(args[:is_batch])
    |> OperationScope.filter_from_action(args[:action])
    |> Query.join(:left, [o], r in assoc(o, :revision))
    |> Query.where([o, r], r.project_id == ^project.id or o.project_id == ^project.id)
    |> OperationScope.order_last_to_first()
    |> Repo.paginate(page: args[:page], page_size: args[:page_size])
    |> Paginated.format()
    |> (&{:ok, &1}).()
  end

  @spec list_operations(Operation.t(), map(), GraphQLContext.t()) :: {:ok, Paginated.t(Operation.t())}
  def list_operations(operation, args, _) do
    operation
    |> Ecto.assoc(:operations)
    |> Repo.paginate(page: args[:page])
    |> Paginated.format()
    |> (&{:ok, &1}).()
  end

  @spec list_translation(Translation.t(), map(), GraphQLContext.t()) :: {:ok, Paginated.t(Operation.t())}
  def list_translation(translation, args, _) do
    translation
    |> Ecto.assoc(:operations)
    |> OperationScope.filter_from_user(args[:user_id])
    |> OperationScope.filter_from_batch(args[:is_batch])
    |> OperationScope.filter_from_action(args[:action])
    |> Query.where([o, _], o.action not in ["update_proposed"])
    |> OperationScope.order_last_to_first()
    |> Repo.paginate(page: args[:page])
    |> Paginated.format()
    |> (&{:ok, &1}).()
  end

  @spec show_project(Project.t(), %{id: String.t()}, GraphQLContext.t()) :: {:ok, Operation.t() | nil}
  def show_project(_project, %{id: id}, _info) do
    Operation
    |> Query.where(id: ^id)
    |> Repo.one()
    |> (&{:ok, &1}).()
  end
end
