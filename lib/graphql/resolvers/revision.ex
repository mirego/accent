defmodule Accent.GraphQL.Resolvers.Revision do
  require Ecto.Query
  alias Ecto.Query

  alias Accent.Scopes.Revision, as: RevisionScope

  alias Accent.{
    Language,
    Plugs.GraphQLContext,
    Project,
    Repo,
    Revision,
    RevisionManager
  }

  alias Movement.Builders.NewSlave, as: NewSlaveBuilder
  alias Movement.Builders.RevisionCorrectAll, as: RevisionCorrectAllBuilder
  alias Movement.Builders.RevisionUncorrectAll, as: RevisionUncorrectAllBuilder
  alias Movement.Context
  alias Movement.Persisters.NewSlave, as: NewSlavePersister
  alias Movement.Persisters.RevisionCorrectAll, as: RevisionCorrectAllPersister
  alias Movement.Persisters.RevisionUncorrectAll, as: RevisionUncorrectAllPersister

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

    %Context{}
    |> Context.assign(:project, project)
    |> Context.assign(:language, language)
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
  def show_project(project, %{id: id}, _) do
    Revision
    |> RevisionScope.from_project(project.id)
    |> RevisionScope.with_stats()
    |> Query.where(id: ^id)
    |> Repo.one()
    |> (&{:ok, &1}).()
  end

  def show_project(project, _, _) do
    Revision
    |> RevisionScope.from_project(project.id)
    |> RevisionScope.with_stats()
    |> RevisionScope.master()
    |> Repo.one()
    |> (&{:ok, &1}).()
  end

  @spec list_project(Project.t(), any(), GraphQLContext.t()) :: {:ok, [Revision.t()]}
  def list_project(project, _, _) do
    project
    |> Ecto.assoc(:revisions)
    |> RevisionScope.with_stats()
    |> Query.order_by(desc: :master, asc: :inserted_at)
    |> Repo.all()
    |> (&{:ok, &1}).()
  end

  defp refresh_stats(revision) do
    Revision
    |> RevisionScope.with_stats()
    |> Query.where(id: ^revision.id)
    |> Repo.one()
  end
end
