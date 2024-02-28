defmodule Movement.Persisters.NewVersion do
  @moduledoc false
  @behaviour Movement.Persister

  alias Accent.Repo
  alias Accent.Version
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

  defp assign_new_version(%Movement.Context{assigns: assigns} = context) do
    %Version{}
    |> Version.changeset(%{
      "project_id" => assigns[:project].id,
      "user_id" => assigns[:user_id],
      "name" => assigns[:name],
      "tag" => assigns[:tag],
      "copy_on_update_translation" => assigns[:copy_on_update_translation]
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
