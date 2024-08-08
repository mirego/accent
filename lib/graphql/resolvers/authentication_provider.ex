defmodule Accent.GraphQL.Resolvers.AuthenticationProvider do
  @moduledoc false
  alias Accent.Plugs.GraphQLContext

  @spec list(any(), any(), GraphQLContext.t()) :: {:ok, list(%{id: atom()})}
  def list(_, _, _) do
    {:ok, Enum.map(config()[:providers], &%{id: elem(&1, 0)})}
  end

  defp config do
    Application.get_env(:ueberauth, Ueberauth)
  end
end
