defmodule Accent.Integration do
  @moduledoc false
  use Accent.Schema

  schema "integrations" do
    field(:service, :string)
    field(:events, {:array, :string})

    embeds_one(:data, IntegrationData, on_replace: :update) do
      field(:url)
      field(:repository)
      field(:token)
      field(:default_ref)
      field(:account_name)
      field(:account_key)
      field(:container_name)
    end

    belongs_to(:project, Accent.Project)
    belongs_to(:user, Accent.User)

    timestamps()
  end
end
