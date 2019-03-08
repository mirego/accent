defmodule Accent.Scopes.Operation do
  import Ecto.Query, only: [from: 2]

  @doc """
  ## Examples

    iex> Accent.Scopes.Operation.filter_from_user(Accent.Operation, nil)
    Accent.Operation
    iex> Accent.Scopes.Operation.filter_from_user(Accent.Operation, "test")
    #Ecto.Query<from o0 in Accent.Operation, where: o0.user_id == ^"test">
  """
  @spec filter_from_user(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def filter_from_user(query, nil), do: query

  def filter_from_user(query, user_id) do
    from(query, where: [user_id: ^user_id])
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Operation.filter_from_action(Accent.Operation, nil)
    Accent.Operation
    iex> Accent.Scopes.Operation.filter_from_action(Accent.Operation, "test")
    #Ecto.Query<from o0 in Accent.Operation, where: o0.action == ^"test">
  """
  @spec filter_from_action(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def filter_from_action(query, nil), do: query

  def filter_from_action(query, action) do
    from(query, where: [action: ^action])
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Operation.filter_from_batch(Accent.Operation, nil)
    Accent.Operation
    iex> Accent.Scopes.Operation.filter_from_batch(Accent.Operation, "test")
    Accent.Operation
    iex> Accent.Scopes.Operation.filter_from_batch(Accent.Operation, true)
    #Ecto.Query<from o0 in Accent.Operation, where: o0.batch == ^true>
  """
  @spec filter_from_batch(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def filter_from_batch(query, nil), do: query
  def filter_from_batch(query, batch) when not is_boolean(batch), do: query

  def filter_from_batch(query, batch) do
    from(query, where: [batch: ^batch])
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Operation.order_last_to_first(Accent.Operation)
    #Ecto.Query<from o0 in Accent.Operation, order_by: [desc: o0.inserted_at, asc: o0.batch]>
  """
  @spec order_last_to_first(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def order_last_to_first(query) do
    from(query, order_by: [desc: :inserted_at, asc: :batch])
  end

  @doc """
  ## Examples

    iex> Accent.Scopes.Operation.ignore_actions(Accent.Operation, "action", nil)
    Accent.Operation
    iex> Accent.Scopes.Operation.ignore_actions(Accent.Operation, nil, true)
    Accent.Operation
    iex> Accent.Scopes.Operation.ignore_actions(Accent.Operation, nil, nil)
    #Ecto.Query<from o0 in Accent.Operation, where: is_nil(o0.batch_operation_id)>
  """
  @spec ignore_actions(Ecto.Queryable.t(), any(), any()) :: Ecto.Queryable.t()
  def ignore_actions(query, nil, nil) do
    from(o in query, where: is_nil(o.batch_operation_id))
  end

  def ignore_actions(query, _action_argument, _batch_argument), do: query
end
