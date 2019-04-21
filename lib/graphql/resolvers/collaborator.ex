defmodule Accent.GraphQL.Resolvers.Collaborator do
  alias Accent.{
    Collaborator,
    CollaboratorCreator,
    CollaboratorUpdater,
    Hook,
    Plugs.GraphQLContext,
    Project,
    Repo
  }

  @typep collaborator_operation :: {:ok, %{collaborator: Collaborator.t() | nil, errors: [String.t()] | nil}}

  @spec create(Project.t(), %{email: String.t(), role: String.t()}, GraphQLContext.t()) :: collaborator_operation
  def create(project, %{email: email, role: role}, info) do
    params = %{
      "email" => email,
      "role" => role,
      "project_id" => project.id,
      "assigner_id" => info.context[:conn].assigns[:current_user].id
    }

    case CollaboratorCreator.create(params) do
      {:ok, collaborator} ->
        Accent.Hook.notify(%Hook.Context{
          event: "create_collaborator",
          project: project,
          user: info.context[:conn].assigns[:current_user],
          payload: %{
            collaborator: collaborator
          }
        })

        {:ok, %{collaborator: collaborator, errors: nil}}

      {:error, _reason} ->
        {:ok, %{collaborator: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec update(Collaborator.t(), %{role: String.t()}, GraphQLContext.t()) :: collaborator_operation
  def update(collaborator, %{role: role}, _info) do
    case CollaboratorUpdater.update(collaborator, %{"role" => role}) do
      {:ok, collaborator} ->
        {:ok, %{collaborator: collaborator, errors: nil}}

      {:error, _reason} ->
        {:ok, %{collaborator: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec delete(Collaborator.t(), map(), GraphQLContext.t()) :: collaborator_operation
  def delete(collaborator, _, _) do
    case Repo.delete(collaborator) do
      {:ok, _collaborator} ->
        {:ok, %{collaborator: collaborator, errors: nil}}

      {:error, _reason} ->
        {:ok, %{collaborator: nil, errors: ["unprocessable_entity"]}}
    end
  end
end
