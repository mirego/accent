defmodule Accent.GraphQL.ErrorReporting do
  @moduledoc false
  require Logger

  def run(%{result: %{errors: errors}, source: source} = blueprint, _) when not is_nil(errors) do
    Logger.error("""
    #{operation_name(Absinthe.Blueprint.current_operation(blueprint))}

    Errors:
    #{inspect(errors)}

    Source:
    #{inspect(source)}
    """)

    {:ok, blueprint}
  end

  def run(blueprint, _) do
    {:ok, blueprint}
  end

  defp operation_name(nil), do: nil
  defp operation_name(operation), do: operation.name
end
