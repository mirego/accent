defmodule Accent.RevisionMasterPromoter do
  alias Accent.{Repo, Revision}

  require Ecto.Query

  import Ecto.Changeset

  def promote(revision: revision = %{master: true}) do
    revision
    |> change()
    |> add_error(:master, "invalid")
    |> Repo.update()
  end

  def promote(revision: revision) do
    revision
    |> change()
    |> put_change(:master, true)
    |> put_change(:master_revision_id, nil)
    |> prepare_changes(fn changeset ->
      Revision
      |> Ecto.Query.where([r], r.id != ^changeset.data.id)
      |> Ecto.Query.where([r], r.project_id == ^changeset.data.project_id)
      |> changeset.repo.update_all(set: [master_revision_id: changeset.data.id, master: false])

      changeset
    end)
    |> Repo.update()
  end
end
