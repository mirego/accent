defmodule Accent.GraphQL.Types.Lint do
  use Absinthe.Schema.Notation

  object :lint_translation_message_context do
    field(:text, non_null(:string))
    field(:offset, non_null(:integer))
    field(:length, non_null(:integer))
  end

  object :lint_translation_message_replacement do
    field(:value, non_null(:string))
  end

  object :lint_translation_message_rule do
    field(:id, non_null(:id))
    field(:description, :string)
  end

  object :lint_translation_message do
    field(:text, non_null(:string))
    field(:context, :lint_translation_message_context)
    field(:rule, non_null(:lint_translation_message_rule))
    field(:replacements, non_null(list_of(non_null(:lint_translation_message_replacement))))
  end
end
