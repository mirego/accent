defmodule Accent.GraphQL.Resolvers.MachineTranslationsConfig do
  alias Accent.{
    MachineTranslationsConfigManager,
    Plugs.GraphQLContext,
    Project
  }

  @spec save(Project.t(), any(), GraphQLContext.t()) :: {:ok, Project.t() | nil}
  def save(project, args, _info) do
    case MachineTranslationsConfigManager.save(project, args) do
      {:ok, %{project: project}} ->
        {:ok, %{project: project, errors: nil}}

      {:error, _reason, _, _} ->
        {:ok, %{project: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec delete(Project.t(), any(), GraphQLContext.t()) :: {:ok, Project.t() | nil}
  def delete(project, _args, _info) do
    case MachineTranslationsConfigManager.delete(project) do
      {:ok, %{project: project}} ->
        {:ok, %{project: project, errors: nil}}

      {:error, _reason, _, _} ->
        {:ok, %{project: nil, errors: ["unprocessable_entity"]}}
    end
  end
end
