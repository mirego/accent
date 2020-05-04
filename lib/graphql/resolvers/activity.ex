defmodule Accent.GraphQL.Resolvers.Activity do
  require Ecto.Query
  alias Ecto.Query

  alias Accent.Scopes.Operation, as: OperationScope

  alias Accent.{
    GraphQL.Paginated,
    Operation,
    Plugs.GraphQLContext,
    PreviousTranslation,
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
    |> Paginated.paginate(args)
    |> Paginated.format()
    |> (&{:ok, &1}).()
  end

  @spec list_operations(Operation.t(), map(), GraphQLContext.t()) :: {:ok, Paginated.t(Operation.t())}
  def list_operations(operation, args, _) do
    operation
    |> Ecto.assoc(:operations)
    |> Paginated.paginate(args)
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
    |> OperationScope.order_last_to_first()
    |> Paginated.paginate(args)
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

  @doc """
    ## Examples:

    iex> previous_translation_text(%{corrected_text: nil, proposed_text: "foo"}, %{}, %{})
    {:ok, "foo"}
    iex> previous_translation_text(%{corrected_text: "bar", proposed_text: "foo"}, %{}, %{})
    {:ok, "bar"}
    iex> previous_translation_text(%{corrected_text: nil, proposed_text: nil}, %{}, %{})
    {:ok, nil}
  """
  @spec previous_translation_text(PreviousTranslation.t(), map(), GraphQLContext.t()) :: {:ok, String.t() | nil}
  def previous_translation_text(translation, _, _) do
    {:ok, translation.corrected_text || translation.proposed_text}
  end

  @doc """
    ## Examples:

    iex> activity_type(%{translation_id: 1, revision_id: nil}, %{}, %{})
    {:ok, :translation}
    iex> activity_type(%{translation_id: nil, revision_id: 1}, %{}, %{})
    {:ok, :revision}
    iex> activity_type(%{translation_id: nil, revision_id: nil, key: "foo"}, %{}, %{})
    {:ok, :project}
  """
  @spec activity_type(Operation.t(), map(), GraphQLContext.t()) :: {:ok, :translation | :revision | :project}
  def activity_type(operation, _, _) do
    cond do
      not is_nil(operation.translation_id) -> {:ok, :translation}
      not is_nil(operation.revision_id) -> {:ok, :revision}
      true -> {:ok, :project}
    end
  end
end
