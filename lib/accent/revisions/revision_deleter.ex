defmodule Accent.RevisionDeleter do
  alias Accent.Repo
  alias Ecto.Multi

  def delete(revision: %{master: true}), do: {:error, "can't delete master language"}

  def delete(revision: revision) do
    translations = Ecto.assoc(revision, :translations)
    operations = Ecto.assoc(revision, :operations)

    Multi.new()
    |> Multi.delete_all(:operations, operations)
    |> Multi.delete_all(:translations, translations)
    |> Multi.delete(:revision, revision)
    |> Repo.transaction()
  end
end
