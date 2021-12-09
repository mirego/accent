defmodule Accent.TranslationLint do
  use Accent.Schema

  embedded_schema do
    embeds_many :messages, Message do
      field(:check, :any, virtual: true)
      field(:text, :string)

      embeds_many :replacement, Replacement do
        field(:label, :string)
        field(:value, :string)
      end
    end

    belongs_to(:translation, Accent.Translation)
  end
end
