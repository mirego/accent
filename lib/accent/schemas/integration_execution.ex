defmodule Accent.IntegrationExecution do
  @moduledoc false
  use Accent.Schema

  schema "integration_executions" do
    field(:state, Ecto.Enum, values: [:success, :error], default: :success)
    field(:data, :map, default: %{})
    field(:results, :map, default: %{})

    belongs_to(:integration, Accent.Integration)
    belongs_to(:version, Accent.Version)
    belongs_to(:user, Accent.User)

    timestamps()
  end
end
