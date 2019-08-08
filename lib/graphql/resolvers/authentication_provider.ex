defmodule Accent.GraphQL.Resolvers.AuthenticationProvider do
  @spec list(any(), any(), GraphQLContext.t()) :: {:ok, list(%{id: String.t()})}
  def list(_, _, _) do
    {:ok, data()}
  end

  def data do
    Enum.map(config()[:providers], fn {id, _} -> %{id: id} end)
  end

  def config do
    Application.get_env(:ueberauth, Ueberauth)
  end
end
