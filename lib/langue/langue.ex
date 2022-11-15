defmodule Langue do
  @format_modules [
    Langue.Formatter.Android,
    Langue.Formatter.CSV,
    Langue.Formatter.Es6Module,
    Langue.Formatter.Gettext,
    Langue.Formatter.JavaProperties,
    Langue.Formatter.JavaPropertiesXml,
    Langue.Formatter.Json,
    Langue.Formatter.Rails,
    Langue.Formatter.SimpleJson,
    Langue.Formatter.Strings,
    Langue.Formatter.LaravelPhp,
    Langue.Formatter.GoI18nJson,
    Langue.Formatter.XLIFF12,
    Langue.Formatter.Resx20
  ]

  for module <- @format_modules, name = module.name() do
    def parser_from_format(unquote(name)), do: {:ok, &unquote(module).parse(&1)}
  end

  def parser_from_format(_), do: {:error, :unknown_parser}

  for module <- @format_modules, name = module.name() do
    def serializer_from_format(unquote(name)), do: {:ok, &unquote(module).serialize(&1)}
  end

  def serializer_from_format(_), do: {:error, :unknown_serializer}

  def placeholder_regex do
    @format_modules
    |> Enum.map(& &1.placeholder_regex())
    |> Enum.reject(&(&1 === :not_supported))
  end
end
