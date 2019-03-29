defmodule Langue do
  @formats [
    Android,
    CSV,
    Es6Module,
    Gettext,
    JavaProperties,
    JavaPropertiesXml,
    Json,
    Rails,
    SimpleJson,
    Strings,
    LaravelPhp,
    GoI18nJson,
    XLIFF12
  ]

  for format <- @formats, module = Module.concat([Langue, Formatter, format]), name = module.name() do
    def parser_from_format(unquote(name)), do: {:ok, &unquote(module).parse(&1)}
  end

  def parser_from_format(_), do: {:error, :unknown_parser}

  for format <- @formats, module = Module.concat([Langue, Formatter, format]), name = module.name() do
    def serializer_from_format(unquote(name)), do: {:ok, &unquote(module).serialize(&1)}
  end

  def serializer_from_format(_), do: {:error, :unknown_serializer}
end
