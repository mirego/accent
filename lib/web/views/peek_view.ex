defmodule Accent.PeekView do
  use Phoenix.View, root: "lib/web/templates"

  def render("index.json", %{operations: operations}) do
    data =
      Enum.reduce(operations, %{}, fn {revision_id, operations}, acc ->
        Map.put(acc, revision_id, render_many(operations, Accent.PeekView, "operation.json"))
      end)

    stats =
      Enum.reduce(operations, %{}, fn {revision_id, operations}, acc ->
        stat = fetch_stats(operations)

        Map.put(acc, revision_id, stat)
      end)

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
    operations
    |> Enum.group_by(&Map.get(&1, :action))
    |> Enum.reduce(%{}, fn {action, operations}, acc ->
      Map.put(acc, action, Enum.count(operations))
    end)
  end
end
