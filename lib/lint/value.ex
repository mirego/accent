defmodule Accent.Lint.Value do
  alias __MODULE__

  @type t :: %Value{}

  defstruct entry: nil, messages: []
end
