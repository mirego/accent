defmodule Accent.Revisions.DeleteWorker do
  use Oban.Worker, queue: :operations

  alias Accent.Repo

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    revision = Repo.get!(Accent.Revision, args["revision_id"])
    Repo.transaction(fn -> Repo.delete(revision) end, timeout: :infinity)

    :ok
  end
end
