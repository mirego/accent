defmodule Accent.Integration do
  use Accent.Schema

  schema "integrations" do
    field(:service, :string)
    field(:events, {:array, :string})

    embeds_one(:data, Accent.IntegrationData, on_replace: :update)
    belongs_to(:project, Accent.Project)
    belongs_to(:user, Accent.User)

    timestamps()
  end
end
