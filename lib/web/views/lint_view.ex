defmodule Accent.LintView do
  use Phoenix.View, root: "lib/web/templates"

  def render("index.json", %{lint_translations: lint_translations}) do
    data =
      Enum.map(lint_translations, fn lint_translation ->
        entry = lint_translation.entry

        %{
          id: lint_translation.id,
          key: entry.key,
          text: entry.value,
          master: entry.is_master,
          comment: entry.comment,
          index: entry.index,
          locked: entry.locked,
          plural: entry.plural,
          placeholders: entry.placeholders,
          messages:
            Enum.map(lint_translation.messages, fn message ->
              %{
                check: message.check,
                text: message.text,
                replacement:
                  message.replacement &&
                    %{
                      label: message.replacement.label,
                      value: message.replacement.value
                    }
              }
            end)
        }
      end)

    %{data: %{lint_translations: data}}
  end
end
