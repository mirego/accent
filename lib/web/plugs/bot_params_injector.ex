defmodule Accent.Plugs.BotParamsInjector do
  @moduledoc false
  use Plug.Builder

  plug(:assign_project_id)

  @doc """
  If the current_user is the project’s bot, we automatically add the project id in the params.
  This makes the param not required in the URL when making calls such as `sync` or `merge`.

  Fallback to doing nothing with the connection
  """
  def assign_project_id(%{assigns: %{current_user: %{bot: true} = user}} = conn, _) do
    user.permissions
    |> Map.to_list()
    |> case do
      [{project_id, _} | _] ->
        project = %{"project_id" => project_id}

        conn
        |> update_in([Access.key(:params)], &Map.merge(&1, project))
        |> update_in([Access.key(:params), "variables"], fn
          nil -> project
          variables -> Map.merge(variables, project)
        end)

      _ ->
        conn
        |> send_resp(401, "Unauthorized")
        |> halt()
    end
  end

  def assign_project_id(conn, _), do: conn
end
