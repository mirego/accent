defmodule Accent.MachineTranslations.Provider.NotImplemented do
  defstruct config: nil

  defimpl Accent.MachineTranslations.Provider do
    def id(_provider), do: :not_implemented
    def enabled?(_provider), do: false
    def translate(_provider, entries, _source_language, _target_language), do: entries
  end
end
