defmodule Accent.Lint.Rules.Spelling.Gateway do
  @callback check(String.t(), String.t()) :: list(map())
end
