defmodule Accent.GraphQL.Resolvers.Document do
  @moduledoc false
  alias Accent.Document
  alias Accent.DocumentManager
  alias Accent.GraphQL.Paginated
  alias Accent.Plugs.GraphQLContext
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Scopes.Document, as: DocumentScope
  alias Movement.Builders.DocumentDelete, as: DocumentDeleteBuilder
  alias Movement.Context
  alias Movement.Persisters.DocumentDelete, as: DocumentDeletePersister

  require Ecto.Query

  @typep document_operation :: {:ok, %{document: Document.t() | nil, errors: [String.t()] | nil}}

  @spec delete(Document.t(), any(), GraphQLContext.t()) :: document_operation
  def delete(document, _, info) do
    %Context{}
    |> Context.assign(:document, document)
    |> Context.assign(:user_id, info.context[:conn].assigns[:current_user].id)
    |> DocumentDeleteBuilder.build()
    |> DocumentDeletePersister.persist()
    |> case do
      {:ok, _} ->
        {:ok, %{document: document, errors: nil}}

      {:error, _reason} ->
        {:ok, %{document: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec update(Document.t(), %{path: String.t()}, GraphQLContext.t()) :: document_operation
  def update(document, args, _info) do
    case DocumentManager.update(document, args) do
      {:ok, document} ->
        {:ok, %{document: document, errors: nil}}

      {:error, _} ->
        {:ok, %{document: document, errors: ["unprocessable_entity"]}}
    end
  end

  @spec show_project(Project.t(), %{id: String.t()}, GraphQLContext.t()) ::
          {:ok, Document.t() | nil}
  def show_project(project, %{id: id}, _) do
    Document
    |> DocumentScope.from_project(project.id)
    |> DocumentScope.with_stats(exclude_empty_translations: true)
    |> Ecto.Query.where(id: ^id)
    |> Repo.one()
    |> then(&{:ok, &1})
  end

  @spec list_project(
          Project.t(),
          %{page: number(), exclude_empty_translations: boolean()},
          GraphQLContext.t()
        ) ::
          {:ok, Paginated.t(Document.t())}
  def list_project(project, args, _) do
    Document
    |> DocumentScope.from_project(project.id)
    |> DocumentScope.with_stats(exclude_empty_translations: args.exclude_empty_translations)
    |> Ecto.Query.order_by(asc: :path)
    |> Paginated.paginate(args)
    |> Paginated.format()
    |> then(&{:ok, &1})
  end
end
