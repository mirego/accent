defmodule Movement.Persisters.NewVersion do
  @behaviour Movement.Persister

  alias Accent.{Repo, Version}
  alias Movement.Persisters.Base, as: BasePersister

  @batch_action "create_version"

  def persist(context) do
    Repo.transaction(fn ->
      context
      |> assign_new_version()
      |> Movement.Context.assign(:batch_action, @batch_action)
      |> BasePersister.execute()
    end)
  end

  defp assign_new_version(context = %Movement.Context{assigns: assigns}) do
    %Version{}
    |> Version.changeset(%{
      "project_id" => assigns[:project].id,
      "user_id" => assigns[:user_id],
      "name" => assigns[:name],
      "tag" => assigns[:tag]
    })
    |> Repo.insert()
    |> case do
      {:ok, version} ->
        Movement.Context.assign(context, :version, version)

      {:error, changeset} ->
        Repo.rollback(changeset)
    end
  end
end
