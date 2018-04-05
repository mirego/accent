defmodule Accent.GraphQL.Resolvers.AccessToken do
  import Ecto.Query, only: [from: 2]

  alias Accent.{
    AccessToken,
    Plugs.GraphQLContext,
    Project,
    Repo
  }

  @spec show_project(Project.t(), any(), GraphQLContext.t()) :: {:ok, AccessToken.t() | nil}
  def show_project(project, _, _) do
    from(
      access_token in AccessToken,
      inner_join: user in assoc(access_token, :user),
      inner_join: collaboration in assoc(user, :collaborations),
      where: collaboration.project_id == ^project.id,
      where: user.bot == true
    )
    |> Repo.one()
    |> case do
      %AccessToken{token: token} -> {:ok, token}
      _ -> {:ok, nil}
    end
  end
end
