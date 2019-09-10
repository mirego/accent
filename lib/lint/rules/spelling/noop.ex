defmodule Accent.Lint.Rules.Spelling.Noop do
  @behaviour Accent.Lint.Rules.Spelling.Gateway

  def check(_value, _language), do: []
end
