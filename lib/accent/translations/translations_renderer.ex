defmodule Accent.TranslationsRenderer do
  alias Langue.Formatter.Strings.Serializer, as: StringsSerializer
  alias Langue.Formatter.Rails.Serializer, as: RailsSerializer
  alias Langue.Formatter.Json.Serializer, as: JsonSerializer
  alias Langue.Formatter.SimpleJson.Serializer, as: SimpleJsonSerializer
  alias Langue.Formatter.Es6Module.Serializer, as: Es6ModuleSerializer
  alias Langue.Formatter.Android.Serializer, as: AndroidSerializer
  alias Langue.Formatter.JavaProperties.Serializer, as: JavaPropertiesSerializer
  alias Langue.Formatter.JavaPropertiesXml.Serializer, as: JavaPropertiesXmlSerializer
  alias Langue.Formatter.Gettext.Serializer, as: GettextSerializer

  def render(args) do
    serializer = fetch_serializer(args[:document_format])
    entries = fetch_entries(args[:translations])

    parser_result = %Langue.Formatter.ParserResult{
      entries: entries,
      locale: args[:document_locale],
      top_of_the_file_comment: args[:document_top_of_the_file_comment],
      header: args[:document_header]
    }

    try do
      serializer.(parser_result)
    catch
      _ -> Langue.Formatter.SerializerResult.empty()
    end
  end

  defp fetch_serializer(format) do
    case serializer_from_format(format) do
      {:ok, serializer} -> serializer
    end
  end

  defp fetch_entries(translations) do
    Enum.map(translations, fn translation ->
      %Langue.Entry{
        key: translation.key,
        value: translation.corrected_text,
        comment: translation.file_comment,
        index: translation.file_index,
        value_type: translation.value_type
      }
    end)
  end

  defp serializer_from_format("strings"), do: {:ok, &StringsSerializer.serialize/1}
  defp serializer_from_format("rails_yml"), do: {:ok, &RailsSerializer.serialize/1}
  defp serializer_from_format("json"), do: {:ok, &JsonSerializer.serialize/1}
  defp serializer_from_format("simple_json"), do: {:ok, &SimpleJsonSerializer.serialize/1}
  defp serializer_from_format("android_xml"), do: {:ok, &AndroidSerializer.serialize/1}
  defp serializer_from_format("es6_module"), do: {:ok, &Es6ModuleSerializer.serialize/1}
  defp serializer_from_format("java_properties"), do: {:ok, &JavaPropertiesSerializer.serialize/1}
  defp serializer_from_format("java_properties_xml"), do: {:ok, &JavaPropertiesXmlSerializer.serialize/1}
  defp serializer_from_format("gettext"), do: {:ok, &GettextSerializer.serialize/1}
  defp serializer_from_format(_), do: {:error, :unknown_serializer}
end
