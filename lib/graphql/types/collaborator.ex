defmodule Accent.GraphQL.Types.Collaborator do
  @moduledoc false
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 2]

  interface :collaborator do
    field(:id, non_null(:id))
    field(:assigner, :user)
    field(:email, :string)
    field(:role, :role)
    field(:is_pending, :boolean)
    field(:inserted_at, non_null(:datetime))
    field(:user, :user)

    resolve_type(fn
      %{user_id: nil}, _ -> :pending_collaborator
      %{}, _ -> :confirmed_collaborator
    end)
  end

  object :confirmed_collaborator do
    field(:id, non_null(:id))
    field(:user, :user, resolve: dataloader(Accent.User))
    field(:assigner, :user, resolve: dataloader(Accent.User, :assigner))
    field(:email, :string)
    field(:role, :role)
    field(:is_pending, :boolean, resolve: fn _, _ -> {:ok, false} end)
    field(:inserted_at, non_null(:datetime))

    interface(:collaborator)
  end

  object :pending_collaborator do
    field(:id, non_null(:id))
    field(:user, :user, resolve: fn _, _ -> {:ok, nil} end)
    field(:assigner, :user, resolve: dataloader(Accent.User, :assigner))
    field(:email, :string)
    field(:role, :role)
    field(:is_pending, :boolean, resolve: fn _, _ -> {:ok, true} end)
    field(:inserted_at, non_null(:datetime))

    interface(:collaborator)
  end
end
