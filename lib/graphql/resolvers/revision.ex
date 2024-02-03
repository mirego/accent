defmodule Accent.GraphQL.Resolvers.Revision do
  @moduledoc false
  alias Accent.Language
  alias Accent.Plugs.GraphQLContext
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.RevisionManager
  alias Accent.Scopes.Revision, as: RevisionScope
  alias Ecto.Query
  alias Movement.Builders.NewSlave, as: NewSlaveBuilder
  alias Movement.Builders.RevisionCorrectAll, as: RevisionCorrectAllBuilder
  alias Movement.Builders.RevisionUncorrectAll, as: RevisionUncorrectAllBuilder
  alias Movement.Context
  alias Movement.Persisters.NewSlave, as: NewSlavePersister
  alias Movement.Persisters.RevisionCorrectAll, as: RevisionCorrectAllPersister
  alias Movement.Persisters.RevisionUncorrectAll, as: RevisionUncorrectAllPersister

  require Ecto.Query

  @typep revision_operation :: {:ok, %{revision: Revision.t() | nil, errors: [String.t()] | nil}}

  @spec delete(Revision.t(), any(), GraphQLContext.t()) :: revision_operation
  def delete(revision, _, _) do
    case RevisionManager.delete(revision) do
      {:ok, %{revision: revision}} ->
        {:ok, %{revision: revision, errors: nil}}

      {:error, _} ->
        {:ok, %{revision: revision, errors: ["unprocessable_entity"]}}
    end
  end

  @spec update(Revision.t(), any(), GraphQLContext.t()) :: revision_operation
  def update(revision, args, _) do
    case RevisionManager.update(revision, args) do
      {:ok, revision} ->
        {:ok, %{revision: revision, errors: nil}}

      {:error, _} ->
        {:ok, %{revision: revision, errors: ["unprocessable_entity"]}}
    end
  end

  @spec promote_master(Revision.t(), any(), GraphQLContext.t()) :: revision_operation
  def promote_master(revision, _, _) do
    case RevisionManager.promote(revision) do
      {:ok, revision} ->
        {:ok, %{revision: revision, errors: nil}}

      {:error, _} ->
        {:ok, %{revision: revision, errors: ["unprocessable_entity"]}}
    end
  end

  @spec create(Project.t(), %{language_id: String.t()}, GraphQLContext.t()) :: revision_operation
  def create(project, args, info) do
    language = Repo.get(Language, args.language_id)
    new_slave_options = parse_new_slave_options(args)

    %Context{}
    |> Context.assign(:project, project)
    |> Context.assign(:language, language)
    |> Context.assign(:new_slave_options, new_slave_options)
    |> Context.assign(:user_id, info.context[:conn].assigns[:current_user].id)
    |> NewSlaveBuilder.build()
    |> NewSlavePersister.persist()
    |> case do
      {:ok, _} ->
        revision =
          Revision
          |> RevisionScope.from_project(project.id)
          |> RevisionScope.from_language(language.id)
          |> Repo.one!()

        {:ok, %{revision: revision, errors: nil}}

      {:error, _reason} ->
        {:ok, %{revision: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec correct_all(Revision.t(), any(), GraphQLContext.t()) :: revision_operation
  def correct_all(revision, _, info) do
    %Context{}
    |> Context.assign(:revision, revision)
    |> Context.assign(:user_id, info.context[:conn].assigns[:current_user].id)
    |> RevisionCorrectAllBuilder.build()
    |> RevisionCorrectAllPersister.persist()
    |> case do
      {:ok, _} ->
        {:ok, %{revision: refresh_stats(revision), errors: nil}}

      {:error, _reason} ->
        {:ok, %{revision: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec uncorrect_all(Revision.t(), any(), GraphQLContext.t()) :: revision_operation
  def uncorrect_all(revision, _, info) do
    %Context{}
    |> Context.assign(:revision, revision)
    |> Context.assign(:user_id, info.context[:conn].assigns[:current_user].id)
    |> RevisionUncorrectAllBuilder.build()
    |> RevisionUncorrectAllPersister.persist()
    |> case do
      {:ok, _} ->
        {:ok, %{revision: refresh_stats(revision), errors: nil}}

      {:error, _reason} ->
        {:ok, %{revision: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec show_project(Project.t(), %{id: String.t()}, GraphQLContext.t()) :: {:ok, Revision.t() | nil}
  def show_project(project, %{id: id} = args, _) do
    Revision
    |> RevisionScope.from_project(project.id)
    |> RevisionScope.with_stats(version_id: args[:version_id])
    |> Query.where(id: ^id)
    |> Repo.one()
    |> then(&{:ok, &1})
  end

  def show_project(project, args, _) do
    Revision
    |> RevisionScope.from_project(project.id)
    |> RevisionScope.with_stats(version_id: args[:version_id])
    |> RevisionScope.master()
    |> Repo.one()
    |> then(&{:ok, &1})
  end

  @spec list_project(Project.t(), any(), GraphQLContext.t()) :: {:ok, [Revision.t()]}
  def list_project(project, args, _) do
    project
    |> Ecto.assoc(:revisions)
    |> Query.join(:inner, [revisions], languages in assoc(revisions, :language), as: :languages)
    |> Query.order_by([revisions, languages: languages], desc: :master, asc: revisions.name, asc: languages.name)
    |> RevisionScope.with_stats(version_id: args[:version_id])
    |> Repo.all()
    |> then(&{:ok, &1})
  end

  defp refresh_stats(revision) do
    Revision
    |> RevisionScope.with_stats()
    |> Query.where(id: ^revision.id)
    |> Repo.one()
  end

  defp parse_new_slave_options(args) do
    options = []
    options = if args[:default_null], do: ["default_null" | options], else: options
    options = if args[:machine_translations_enabled], do: ["machine_translations_enabled" | options], else: options

    options
  end
end
