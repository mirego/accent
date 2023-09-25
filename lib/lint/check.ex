defmodule Accent.Lint.Check do
  @moduledoc false
  @callback applicable(Accent.Lint.entry()) :: boolean()
  @callback enabled?() :: boolean()
  @callback check(Accent.Lint.entry()) :: [Accent.Lint.message()] | Accent.Lint.message() | nil
end
