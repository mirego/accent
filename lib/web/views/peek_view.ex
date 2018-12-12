defmodule Accent.PeekView do
  use Phoenix.View, root: "lib/web/templates"

  def render("index.json", %{operations: operations}) do
    data =
      Enum.reduce(operations, %{}, fn {revision_id, operations}, acc ->
        Map.put(acc, revision_id, render_many(operations, Accent.PeekView, "operation.json"))
      end)

    stats =
      operations
      |> Enum.reduce(%{}, fn {revision_id, operations}, acc ->
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
      "previous-text": operation.previous_translation.corrected_text || operation.previous_translation.proposed_text
    }
  end

  defp fetch_stats(operations) do
    operations
    |> Enum.group_by(&Map.get(&1, :action))
    |> Enum.reduce(%{}, fn {action, operations}, acc ->
      Map.put(acc, action, Enum.count(operations))
    end)
  end
end
