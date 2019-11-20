defmodule Accent.Lint do
  alias Accent.Lint.Message
  alias Accent.Lint.Rules, as: R
  alias Accent.Lint.Value

  @rules [
    &R.DoubleSpaces.lint/2,
    &R.LeadingSpaces.lint/2,
    &R.PlaceholderCount.lint/2,
    &R.Spelling.lint/2,
    &R.ThreeDotsEllipsis.lint/2,
    &R.TrailingColon.lint/2,
    &R.TrailingEllipsis.lint/2,
    &R.TrailingExclamation.lint/2,
    &R.TrailingQuestionMark.lint/2,
    &R.TrailingSpaces.lint/2,
    &R.TrailingStop.lint/2,
    &R.URLCount.lint/2
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

  @spec display_trailing_text(String.t()) :: String.t()
  def display_trailing_text(text) do
    max_length = 12

    if String.length(text) > max_length do
      display_text = String.slice(text, (String.length(text) - max_length)..-1)

      String.pad_leading(display_text, max_length + 1, "…")
    else
      text
    end
  end
end
