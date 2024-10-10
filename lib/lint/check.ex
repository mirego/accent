defmodule Accent.Lint.Check do
  @moduledoc false
  alias Accent.Lint.Config

  @callback applicable(Accent.Lint.entry(), Config.t()) :: boolean()
  @callback enabled?() :: boolean()
  @callback check(Accent.Lint.entry(), Config.t()) :: [Accent.Lint.message()] | Accent.Lint.message() | nil
end
