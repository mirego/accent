defmodule Movement.Persisters.ProjectSync do
  @moduledoc false
  @behaviour Movement.Persister

  import Movement.Context, only: [assign: 3]

  alias Accent.Document
  alias Accent.Repo
  alias Movement.Persisters.Base, as: BasePersister

  def persist(%Movement.Context{operations: []} = context), do: {:ok, {context, []}}

  def persist(context) do
    Repo.transaction(fn ->
      context
      |> persist_document()
      |> BasePersister.execute()
      |> case do
        {context, operations} ->
          context.assigns[:project]
          |> Ecto.Changeset.change(last_synced_at: DateTime.truncate(DateTime.utc_now(), :second))
          |> Ecto.Changeset.optimistic_lock(:sync_lock_version)
          |> Repo.update()

          {context, operations}
      end
    end)
  end

  defp persist_document(%Movement.Context{assigns: %{document_update: nil, document: %{id: id}}} = context)
       when not is_nil(id),
       do: context

  defp persist_document(
         %Movement.Context{assigns: %{document_update: document_update, document: %{id: id} = document}} = context
       )
       when not is_nil(id) do
    document =
      document
      |> Document.changeset(document_update)
      |> Repo.update!()

    assign(context, :document, document)
  end

  defp persist_document(%Movement.Context{assigns: %{document: %{id: id}}} = context) when not is_nil(id), do: context

  defp persist_document(%Movement.Context{assigns: %{document: document}} = context) do
    document =
      document
      |> Document.changeset(context.assigns[:document_update] || %{})
      |> Repo.insert!()

    assign(context, :document, document)
  end
end
