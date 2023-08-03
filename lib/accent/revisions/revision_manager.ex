defmodule Accent.RevisionManager do
  alias Accent.Repo

  import Ecto.Changeset
  import Ecto.Query

  def update(integration, params) do
    integration
    |> cast(params, [:name, :slug])
    |> Repo.update()
  end

  def delete(revision = %{master: true}) do
    changeset =
      revision
      |> change()
      |> add_error(:master, "can't delete master language")

    {:error, changeset}
  end

  def delete(revision) do
    with {:ok, revision} <- Repo.update(change(revision, marked_as_deleted: true)) do
      Oban.insert(Accent.Revisions.DeleteWorker.new(%{revision_id: revision.id}))
      {:ok, %{revision: revision}}
    else
      _ -> {:error, nil}
    end
  end

  def promote(revision = %{master: true}) do
    changeset =
      revision
      |> change()
      |> add_error(:master, "invalid")

    {:error, changeset}
  end

  def promote(revision) do
    revision
    |> change()
    |> put_change(:master, true)
    |> put_change(:master_revision_id, nil)
    |> prepare_changes(&normalize_other_revisions/1)
    |> Repo.update()
  end

  defp normalize_other_revisions(changeset) do
    changeset.data.__struct__
    |> where([r], r.id != ^changeset.data.id)
    |> where([r], r.project_id == ^changeset.data.project_id)
    |> changeset.repo.update_all(set: [master_revision_id: changeset.data.id, master: false])

    changeset
  end
end
