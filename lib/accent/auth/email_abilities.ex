defmodule Accent.EmailAbilities do
  @moduledoc false
  @restricted_actions ~w(
    create_project
  )a

  @any_actions ~w(
    index_permissions
    index_projects
  )a

  def actions_for(email) do
    with restricted_domain when is_binary(restricted_domain) <- Application.get_env(:accent, :restricted_domain),
         false <- String.ends_with?(email, "@" <> restricted_domain) do
      @any_actions
    else
      _ ->
        @restricted_actions ++ @any_actions
    end
  end

  def can?(email, action) do
    action in actions_for(email)
  end
end
