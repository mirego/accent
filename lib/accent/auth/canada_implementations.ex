defimpl Canada.Can, for: Accent.User do
  alias Accent.{User, Project, Revision}

  def can?(%User{permissions: permissions}, action, project_id) when is_binary(project_id) do
    validate_role(permissions, action, project_id)
  end

  def can?(%User{permissions: permissions}, action, %Project{id: project_id}) when is_binary(project_id) do
    validate_role(permissions, action, project_id)
  end

  def can?(%User{permissions: permissions}, action, %Revision{project_id: project_id}) when is_binary(project_id) do
    validate_role(permissions, action, project_id)
  end

  def can?(%User{email: email}, action, _) do
    Accent.EmailAbilities.can?(email, action)
  end

  def can?(_user, _action, nil), do: false

  def validate_role(nil, _action, _project_id), do: false

  def validate_role(permissions, action, project_id) do
    permissions
    |> Map.get(project_id)
    |> Accent.RoleAbilities.can?(action)
  end
end
