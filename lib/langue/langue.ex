defmodule Langue do
  @moduledoc false
  @format_modules Enum.filter(
                    [
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
                    ],
                    & &1.enabled?()
                  )

  def modules, do: @format_modules

  for module <- @format_modules, id = module.id() do
    def parser_from_format(unquote(id)), do: {:ok, &unquote(module).parse(&1)}
  end

  def parser_from_format(_), do: {:error, :unknown_parser}

  for module <- @format_modules, id = module.id() do
    def serializer_from_format(unquote(id)), do: {:ok, &unquote(module).serialize(&1)}
  end

  def serializer_from_format(_), do: {:error, :unknown_serializer}

  for module <- @format_modules, id = module.id() do
    def placeholder_regex_from_format(unquote(id)), do: {:ok, unquote(module).placeholder_regex()}
  end

  def placeholder_regex_from_format(_), do: {:error, :unknown_format}

  def placeholder_regex do
    @format_modules
    |> Enum.map(& &1.placeholder_regex())
    |> Enum.reject(&(&1 === :not_supported))
  end
end
