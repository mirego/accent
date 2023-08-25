defmodule Accent.Prompts.Provider.NotImplemented do
  @moduledoc false
  defstruct config: nil

  defimpl Accent.Prompts.Provider do
    def id(_provider), do: :not_implemented
    def enabled?(_provider), do: false
    def completions(_provider, _prompt, user_input), do: user_input
  end
end
