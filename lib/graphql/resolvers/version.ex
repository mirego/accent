defmodule Accent.GraphQL.Resolvers.Version do
  @moduledoc false
  alias Accent.GraphQL.Paginated
  alias Accent.Plugs.GraphQLContext
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Version
  alias Movement.Builders.NewVersion, as: NewVersionBuilder
  alias Movement.Context
  alias Movement.Persisters.NewVersion, as: NewVersionPersister

  require Ecto.Query

  @typep version_operation :: {:ok, %{version: Version.t() | nil, errors: [String.t()] | nil}}

  @spec create(
          Project.t(),
          %{name: String.t(), tag: String.t(), copy_on_update_translation: boolean()},
          GraphQLContext.t()
        ) :: version_operation
  def create(project, args, info) do
    %Context{}
    |> Context.assign(:project, project)
    |> Context.assign(:name, args[:name])
    |> Context.assign(:tag, args[:tag])
    |> Context.assign(:copy_on_update_translation, args[:copy_on_update_translation])
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

  @spec update(
          Version.t(),
          %{name: String.t(), tag: String.t(), copy_on_update_translation: boolean()},
          GraphQLContext.t()
        ) :: version_operation
  def update(version, args, _info) do
    version
    |> Version.changeset(%{
      name: args[:name],
      tag: args[:tag],
      copy_on_update_translation: args[:copy_on_update_translation] || false
    })
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
    |> then(&{:ok, &1})
  end
end
