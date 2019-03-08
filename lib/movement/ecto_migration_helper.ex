defmodule Movement.EctoMigrationHelper do
  alias Accent.Repo
  alias Movement.Migration

  @doc """
  Update given model by merging the existing parameters and the arguments.
  """
  @spec update(model :: map, params :: map()) :: Migration.t()
  def update(model, params) do
    model
    |> model.__struct__.changeset(params)
    |> Repo.update()
  end

  def insert(model) do
    model
    |> Repo.insert()
  end
end
