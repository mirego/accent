defmodule Accent.Lint do
  alias Accent.Lint.Value
  alias Accent.Lint.Message

  @rules [
    &Accent.Lint.Rules.TrailingSpaces.lint/2,
    &Accent.Lint.Rules.LeadingSpaces.lint/2,
    &Accent.Lint.Rules.URLCount.lint/2,
    &Accent.Lint.Rules.PlaceholderCount.lint/2,
    &Accent.Lint.Rules.Spelling.lint/2
  ]

  @typep entry :: Langue.Entry.t()
  @typep value :: Value.t()
  @typep message :: Message.t()

  @spec lint(list(entry), Keyword.t()) :: list(value)
  def lint(entries, opts) do
    entries
    |> Stream.map(&%Value{entry: &1})
    |> Task.async_stream(fn entry -> Enum.reduce(@rules, entry, & &1.(&2, opts)) end, timeout: :infinity)
    |> Stream.map(&elem(&1, 1))
    |> Enum.to_list()
  end

  @spec add_message(value, message) :: value
  def add_message(value, message) do
    %{
      value
      | messages: [message | value.messages]
    }
  end
end
