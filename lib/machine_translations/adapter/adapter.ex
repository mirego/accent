defmodule Accent.MachineTranslations.Adapter do
  @callback translate_text(String.t(), String.t(), String.t(), Keyword.t()) :: {:ok, Accent.MachineTranslations.TranslatedText.t()} | any()
  @callback translate_list([String.t()], String.t(), String.t(), Keyword.t()) :: {:ok, [Accent.MachineTranslations.TranslatedText.t()]} | any()
end
