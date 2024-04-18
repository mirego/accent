defmodule Accent.GraphQL.Types.Lint do
  @moduledoc false
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  enum :lint_check do
    value(:spelling)
    value(:leading_spaces)
    value(:double_spaces)
    value(:first_letter_case)
    value(:apostrophe_as_single_quote)
    value(:three_dots_ellipsis)
    value(:same_trailing_character)
    value(:trailing_space)
    value(:placeholder_count)
    value(:url_count)
  end

  object :lint_translation_message_replacement do
    field(:value, non_null(:string))
    field(:label, non_null(:string))
  end

  object :lint_translation_message_details do
    field(:spelling_rule_id, :string)
    field(:spelling_rule_description, :string)
  end

  object :lint_translation_message do
    field(:message, :string)
    field(:offset, :integer)
    field(:length, :integer)
    field(:text, non_null(:string))
    field(:check, non_null(:lint_check))
    field(:details, non_null(:lint_translation_message_details))
    field(:replacement, :lint_translation_message_replacement)
  end

  object :project_lint_entry do
    field(:id, non_null(:id))
    field(:project, non_null(:project), resolve: dataloader(Accent.Project))
    field(:check_ids, non_null(list_of(non_null(:id))))
    field(:type, non_null(:lint_entry_type))
    field(:value, :string)
  end

  object :lint_translation do
    field(:messages, list_of(non_null(:lint_translation_message)))
    field(:translation, non_null(:translation), resolve: dataloader(Accent.Translation))
  end
end
