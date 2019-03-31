defmodule Langue.Formatter.XLIFF12.Serializer do
  @behaviour Langue.Formatter.Serializer

  def serialize(%{entries: entries, language: %{slug: slug}, document: %{master_language: master_language, path: path}}) when slug === master_language do
    file_attributes = [
      original: path,
      datatype: "plaintext",
      "source-language": master_language
    ]

    body = [
      {"body", [], Enum.map(entries, &parse_master/1)}
    ]

    serialize_body(file_attributes, body)
  end

  def serialize(%{entries: entries, language: language, document: document}) do
    file_attributes = [
      original: document.path,
      datatype: "plaintext",
      "source-language": document.master_language,
      "target-language": language.slug
    ]

    body = [
      {"body", [], Enum.map(entries, &parse_target/1)}
    ]

    serialize_body(file_attributes, body)
  end

  defp serialize_body(file_attributes, body) do
    render =
      {"file", file_attributes, body}
      |> XmlBuilder.generate()
      |> Kernel.<>("\n")

    %Langue.Formatter.SerializerResult{render: render}
  end

  defp parse_target(%{key: key, master_value: master_value, value: value}) do
    {
      "trans-unit",
      [id: key],
      [
        {"source", [], master_value},
        {"target", [], value}
      ]
    }
  end

  defp parse_master(%{key: key, value: value}) do
    {
      "trans-unit",
      [id: key],
      [
        {"source", [], value},
        {"target", [], ""}
      ]
    }
  end
end
