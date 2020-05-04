defmodule Accent.GraphQL.Resolvers.Version do
  require Ecto.Query

  alias Accent.{
    GraphQL.Paginated,
    Plugs.GraphQLContext,
    Project,
    Repo,
    Version
  }

  alias Movement.Builders.NewVersion, as: NewVersionBuilder
  alias Movement.Context
  alias Movement.Persisters.NewVersion, as: NewVersionPersister

  @typep version_operation :: {:ok, %{version: Version.t() | nil, errors: [String.t()] | nil}}

  @spec create(Project.t(), %{name: String.t(), tag: String.t()}, GraphQLContext.t()) :: version_operation
  def create(project, %{name: name, tag: tag}, info) do
    %Context{}
    |> Context.assign(:project, project)
    |> Context.assign(:name, name)
    |> Context.assign(:tag, tag)
    |> Context.assign(:user_id, info.context[:conn].assigns[:current_user].id)
    |> NewVersionBuilder.build()
    |> NewVersionPersister.persist()
    |> case do
      {:ok, {%{assigns: %{version: version}}, _}} ->
        {:ok, %{version: version, errors: nil}}

      {:error, _reason} ->
        {:ok, %{version: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec update(Version.t(), %{name: String.t(), tag: String.t()}, GraphQLContext.t()) :: version_operation
  def update(version, args, _info) do
    version
    |> Version.changeset(%{name: args[:name], tag: args[:tag]})
    |> Repo.update()
    |> case do
      {:ok, version} ->
        {:ok, %{version: version, errors: nil}}

      {:error, _reason} ->
        {:ok, %{version: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec list_project(Project.t(), %{page: number()}, GraphQLContext.t()) :: {:ok, Paginated.t(Version.t())}
  def list_project(project, args, _) do
    project
    |> Ecto.assoc(:versions)
    |> Ecto.Query.order_by(desc: :inserted_at)
    |> Paginated.paginate(args)
    |> Paginated.format()
    |> (&{:ok, &1}).()
  end
end
