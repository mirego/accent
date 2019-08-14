defmodule Movement.Persisters.ProjectSync do
  @behaviour Movement.Persister

  import Movement.Context, only: [assign: 3]

  alias Accent.{Document, Project, Repo}
  alias Movement.Persisters.Base, as: BasePersister

  @batch_action "sync"

  def persist(context = %Movement.Context{operations: []}), do: {:ok, {context, []}}

  def persist(context) do
    Repo.transaction(fn ->
      context
      |> persist_document()
      |> Movement.Context.assign(:batch_action, @batch_action)
      |> BasePersister.execute()
      |> case do
        {context, operations} ->
          context.assigns[:project]
          |> Project.changeset(%{last_synced_at: DateTime.utc_now()})
          |> Repo.update()

          {context, operations}
      end
    end)
  end

  defp persist_document(context = %Movement.Context{assigns: %{document_update: nil, document: %{id: id}}}) when not is_nil(id), do: context

  defp persist_document(context = %Movement.Context{assigns: %{document_update: document_update, document: document = %{id: id}}}) when not is_nil(id) do
    document =
      document
      |> Document.changeset(document_update)
      |> Repo.update!()

    assign(context, :document, document)
  end

  defp persist_document(context = %Movement.Context{assigns: %{document: %{id: id}}}) when not is_nil(id), do: context

  defp persist_document(context = %Movement.Context{assigns: %{document: document}}) do
    document =
      document
      |> Document.changeset(context.assigns[:document_update] || %{})
      |> Repo.insert!()

    assign(context, :document, document)
  end
end
