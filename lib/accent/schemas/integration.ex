defmodule Accent.Integration do
  @moduledoc false
  use Accent.Schema

  schema "integrations" do
    field(:last_executed_at, :utc_datetime_usec)
    field(:service, :string)
    field(:events, {:array, :string})

    embeds_one(:data, IntegrationData, on_replace: :update) do
      field(:url)
      field(:azure_storage_container_sas)
    end

    belongs_to(:project, Accent.Project)
    belongs_to(:user, Accent.User)
    belongs_to(:last_executed_by_user, Accent.User)

    timestamps()
  end
end
