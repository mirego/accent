defmodule Accent.PeekView do
  use Phoenix.View, root: "lib/web/templates"

  def render("index.json", %{operations: operations}) do
    data =
      Map.new(operations, fn {revision_id, operations} ->
        {revision_id, render_many(operations, Accent.PeekView, "operation.json")}
      end)

    stats = Map.new(operations, fn {revision_id, operations} -> {revision_id, fetch_stats(operations)} end)

    %{data: %{operations: data, stats: stats}}
  end

  def render("operation.json", %{peek: operation}) do
    %{
      text: operation.text,
      key: operation.key,
      action: operation.action,
      "previous-text": previous_text(operation)
    }
  end

  defp previous_text(%{previous_translation: nil}), do: nil

  defp previous_text(%{previous_translation: previous_translation}) do
    previous_translation.corrected_text || previous_translation.proposed_text
  end

  defp fetch_stats(operations) do
    Enum.frequencies_by(operations, & &1.action)
  end
end
