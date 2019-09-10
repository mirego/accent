defmodule Accent.Lint.Message do
  defstruct text: nil, padded_text: nil, fixed_text: nil, replacements: [], context: nil, rule: nil

  defmodule Replacement do
    defstruct value: nil
  end

  defmodule Context do
    defstruct length: nil, text: nil, offset: nil
  end

  defmodule Rule do
    defstruct id: nil, description: nil
  end
end
