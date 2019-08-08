defmodule Accent.DocumentFormat do
  @enforce_keys ~w(name slug extension)a
  defstruct name: nil, slug: nil, extension: nil

  @type t :: struct

  @all [
    %{name: "Simple JSON", slug: "simple_json", extension: "json"},
    %{name: "JSON", slug: "json", extension: "json"},
    %{name: "Apple .strings", slug: "strings", extension: "strings"},
    %{name: "Gettext", slug: "gettext", extension: "po"},
    %{name: "Rails YAML", slug: "rails_yml", extension: "yml"},
    %{name: "ES6 module", slug: "es6_module", extension: "js"},
    %{name: "Android XML", slug: "android_xml", extension: "xml"},
    %{name: "Java properties", slug: "java_properties", extension: "properties"},
    %{name: "Java properties XML", slug: "java_properties_xml", extension: "xml"},
    %{name: "CSV", slug: "csv", extension: "csv"},
    %{name: "Laravel PHP", slug: "laravel_php", extension: "php"},
    %{name: "Go I18n JSON", slug: "go_i18n_json", extension: "json"},
    %{name: "XLIFF 1.2", slug: "xliff_1_2", extension: "xlf"}
  ]

  @doc """
  Slugs used in document changeset validation

  ## Examples
    iex> Accent.DocumentFormat.slugs()
    ["simple_json", "json", "strings", "gettext", "rails_yml", "es6_module", "android_xml", "java_properties", "java_properties_xml", "csv", "laravel_php", "go_i18n_json", "xliff_1_2"]
  """
  defmacro slugs, do: Enum.map(@all, &Map.get(&1, :slug))

  @doc """
  ## Examples

    iex> Accent.DocumentFormat.all()
    [
      %Accent.DocumentFormat{extension: "json", name: "Simple JSON", slug: "simple_json"},
      %Accent.DocumentFormat{extension: "json", name: "JSON", slug: "json"},
      %Accent.DocumentFormat{extension: "strings", name: "Apple .strings", slug: "strings"},
      %Accent.DocumentFormat{extension: "po", name: "Gettext", slug: "gettext"},
      %Accent.DocumentFormat{extension: "yml", name: "Rails YAML", slug: "rails_yml"},
      %Accent.DocumentFormat{extension: "js", name: "ES6 module", slug: "es6_module"},
      %Accent.DocumentFormat{extension: "xml", name: "Android XML", slug: "android_xml"},
      %Accent.DocumentFormat{extension: "properties", name: "Java properties", slug: "java_properties"},
      %Accent.DocumentFormat{extension: "xml", name: "Java properties XML", slug: "java_properties_xml"},
      %Accent.DocumentFormat{extension: "csv", name: "CSV", slug: "csv"},
      %Accent.DocumentFormat{extension: "php", name: "Laravel PHP", slug: "laravel_php"},
      %Accent.DocumentFormat{extension: "json", name: "Go I18n JSON", slug: "go_i18n_json"},
      %Accent.DocumentFormat{extension: "xlf", name: "XLIFF 1.2", slug: "xliff_1_2"}
    ]
  """
  def all, do: Enum.map(@all, &struct(__MODULE__, &1))
end
