defmodule Accent.GraphQL.Resolvers.Document do
  require Ecto.Query

  alias Accent.{
    Document,
    DocumentManager,
    GraphQL.Paginated,
    Plugs.GraphQLContext,
    Project,
    Repo,
    TranslationsCounter
  }

  alias Accent.Scopes.Document, as: DocumentScope

  alias Movement.Builders.DocumentDelete, as: DocumentDeleteBuilder
  alias Movement.Context
  alias Movement.Persisters.DocumentDelete, as: DocumentDeletePersister

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

  @spec show_project(Project.t(), %{id: String.t()}, GraphQLContext.t()) :: {:ok, Document.t() | nil}
  def show_project(project, %{id: id}, _) do
    Document
    |> DocumentScope.from_project(project.id)
    |> Ecto.Query.where(id: ^id)
    |> Repo.one()
    |> merge_stats()
    |> (&{:ok, &1}).()
  end

  @spec list_project(Project.t(), %{page: number()}, GraphQLContext.t()) :: {:ok, Paginated.t(Document.t())}
  def list_project(project, args, _) do
    Document
    |> DocumentScope.from_project(project.id)
    |> Ecto.Query.order_by(desc: :updated_at)
    |> Repo.paginate(page: args[:page])
    |> update_in([Access.key(:entries)], &merge_stats/1)
    |> update_in([Access.key(:entries)], fn entries -> Enum.filter(entries, fn document -> document.translations_count > 0 end) end)
    |> Paginated.format()
    |> (&{:ok, &1}).()
  end

  defp merge_stats(document) when is_map(document) do
    counts = TranslationsCounter.from_documents([document])

    document
    |> Document.merge_stats(counts)
  end

  defp merge_stats(documents) when is_list(documents) do
    counts = TranslationsCounter.from_documents(documents)

    documents
    |> Enum.map(&Document.merge_stats(&1, counts))
  end
end
