defmodule Movement.Builders.TranslationUpdate do
  @moduledoc false
  @behaviour Movement.Builder

  alias Movement.Builders.TranslationTextChange

  def build(
        %Movement.Context{assigns: %{text: text, translation: %{corrected_text: corrected_text, translated: true}}} =
          context
      )
      when text === corrected_text, do: context

  def build(context), do: TranslationTextChange.build(context, "update")
end
