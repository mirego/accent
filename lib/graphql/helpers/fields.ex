defmodule Accent.GraphQL.Helpers.Fields do
  @doc """
  ## Examples

    iex> Accent.GraphQL.Helpers.Fields.field_alias(:foo).(%{foo: "alias"}, nil, nil)
    {:ok, "alias"}
    iex> Accent.GraphQL.Helpers.Fields.field_alias(:foo).(%{foo: %{map: "alias"}}, nil, nil)
    {:ok, %{map: "alias"}}
    iex> Accent.GraphQL.Helpers.Fields.field_alias(:foo).(%{}, nil, nil)
    {:ok, nil}
  """
  def field_alias(field) do
    fn root, _, _ -> {:ok, Map.get(root, field)} end
  end
end
