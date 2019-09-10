defmodule Accent.Lint.Rule do
  alias Accent.Lint.Value

  @callback lint(Value.t(), Keyword.t()) :: {:ok, Value.t()} | {:error, String.t()}
end
