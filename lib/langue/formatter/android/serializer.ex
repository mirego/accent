defmodule Langue.Formatter.Android.Serializer do
  @behaviour Langue.Formatter.Serializer

  @xml_template """
  <?xml version="1.0" encoding="utf-8"?>
  """

  @state %{
    current_array: [],
    current_array_key: nil,
    current_plural: [],
    current_plural_key: nil,
    lines: []
  }

  def serialize(%{entries: entries}) do
    resources =
      entries
      |> Enum.reduce(@state, &parse_line/2)
      |> maybe_add_array_items()
      |> maybe_add_plural_items()
      |> Map.get(:lines)

    resource_render = {"resources", [], resources} |> :mochiweb_html.to_html() |> Enum.join("")

    render = @xml_template <> resource_render

    render =
      render
      |> String.replace("<resources>", "<resources>\n")
      |> String.replace("</resources>", "</resources>\n")
      |> String.replace("<!--", "  <!--")
      |> String.replace("-->", "-->\n")
      |> String.replace("<item", "\n    <item")
      |> String.replace("<string ", "  <string ")
      |> String.replace("<string-array", "  <string-array")
      |> String.replace("<plurals", "  <plurals")
      |> String.replace("</string>", "</string>\n")
      |> String.replace("</string-array>", "\n  </string-array>\n")
      |> String.replace("</plurals>", "\n  </plurals>\n")

    %Langue.Formatter.SerializerResult{render: render}
  end

  defp parse_line(%{key: key, value: value, value_type: "array"}, acc) do
    acc
    |> add_array_item(key, value)
  end

  defp parse_line(%{key: key, value: value, plural: true}, acc) do
    acc
    |> add_plural_item(key, value)
  end

  defp parse_line(%{key: key, value: value, comment: comment}, acc) when is_nil(comment) or comment === "" do
    acc
    |> maybe_add_array_items()
    |> maybe_add_plural_items()
    |> add_string(key, value)
  end

  defp parse_line(%{key: key, value: value, comment: comment}, acc) do
    acc
    |> maybe_add_array_items()
    |> maybe_add_plural_items()
    |> add_comment(comment)
    |> add_string(key, value)
  end

  defp xml_element(item_name, attributes, value) when is_list(value), do: {item_name, attributes, value}
  defp xml_element(item_name, attributes, value), do: {item_name, attributes, sanitize_string_to_value(value)}

  defp sanitize_string_to_value(value) do
    value
    |> String.replace("%@", "%s")
    |> String.replace(~r/%(\d)\$\@/, "%\\g{1}$s")
    |> String.replace("'", "\\'")
  end

  defp add_comment(acc, comment), do: Map.put(acc, :lines, Enum.concat(acc.lines, [{:comment, comment}]))
  defp add_string(acc, key, value), do: Map.put(acc, :lines, Enum.concat(acc.lines, [xml_element("string", [{"name", key}], value)]))

  defp add_array_item(acc, key, value) do
    acc
    |> Map.put(:current_array, Enum.concat(acc[:current_array], [xml_element("item", [], value)]))
    |> Map.put(:current_array_key, acc.current_array_key || key)
  end

  defp add_plural_item(acc, key, value) do
    quantity_key = String.replace(key, ~r/.+\./, "")

    acc
    |> Map.put(:current_plural, Enum.concat(acc[:current_plural], [xml_element("item", [quantity: quantity_key], value)]))
    |> Map.put(:current_plural_key, acc.current_array_key || key)
  end

  defp maybe_add_array_items(acc = %{current_array: array}) when array == [], do: acc

  defp maybe_add_array_items(acc) do
    key = String.replace(acc[:current_array_key], ".__KEY__0", "")

    acc
    |> Map.put(:current_array_key, nil)
    |> Map.put(:current_array, [])
    |> Map.put(:lines, Enum.concat(acc[:lines], [xml_element("string-array", [{"name", key}], acc[:current_array])]))
  end

  defp maybe_add_plural_items(acc = %{current_plural: plural}) when plural == [], do: acc

  defp maybe_add_plural_items(acc) do
    key = String.replace(acc[:current_plural_key], ~r/\..+/, "")

    acc
    |> Map.put(:current_plural_key, nil)
    |> Map.put(:current_plural, [])
    |> Map.put(:lines, Enum.concat(acc[:lines], [xml_element("plurals", [{"name", key}], acc[:current_plural])]))
  end
end
