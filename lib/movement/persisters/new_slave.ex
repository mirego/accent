defmodule Movement.Persisters.NewSlave do
  @behaviour Movement.Persister

  alias Accent.{Repo, Revision}
  alias Movement.Persisters.Base, as: BasePersister

  @batch_action "new_slave"

  def persist(context) do
    Repo.transaction(fn ->
      context
      |> assign_new_revision()
      |> Movement.Context.assign(:batch_action, @batch_action)
      |> BasePersister.execute()
    end)
  end

  defp assign_new_revision(context = %Movement.Context{assigns: assigns}) do
    %Revision{}
    |> Revision.changeset(%{
      "project_id" => assigns[:project].id,
      "language_id" => assigns[:language].id,
      "master_revision_id" => assigns[:master_revision].id,
      "master" => false
    })
    |> Repo.insert()
    |> case do
      {:ok, revision} ->
        Movement.Context.assign(context, :revision, revision)

      {:error, changeset} ->
        Repo.rollback(changeset)
    end
  end
end
