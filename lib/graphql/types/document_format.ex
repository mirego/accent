defmodule Accent.GraphQL.Types.DocumentFormat do
  use Absinthe.Schema.Notation

  enum :document_format do
    value(:json, as: "json")
    value(:simple_json, as: "simple_json")
    value(:strings, as: "strings")
    value(:gettext, as: "gettext")
    value(:rails_yml, as: "rails_yml")
    value(:es6_module, as: "es6_module")
    value(:android_xml, as: "android_xml")
    value(:java_properties, as: "java_properties")
    value(:java_properties_xml, as: "java_properties_xml")
    value(:csv, as: "csv")
    value(:laravel_php, as: "laravel_php")
    value(:go_i18n_json, as: "go_i18n_json")
    value(:xliff_1_2, as: "xliff_1_2")
  end

  object :document_format_item do
    field(:name, non_null(:string))
    field(:extension, non_null(:string))
    field(:slug, non_null(:document_format))
  end
end
