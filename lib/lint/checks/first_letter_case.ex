defmodule Accent.Lint.Checks.FirstLetterCase do
  @moduledoc false
  @behaviour Accent.Lint.Check

  alias Accent.Lint.Message
  alias Accent.Lint.Replacement

  @impl true
  def enabled?, do: true

  @impl true
  def applicable(entry) do
    letter = entry_first_letter(entry.value)
    capitalized_letter = String.capitalize(letter)
    downcased_letter = String.downcase(letter)

    is_binary(entry.master_value) && !entry.is_master && capitalized_letter !== downcased_letter
  end

  @impl true
  def check(entry) do
    master_has_first_letter = starts_with_letter?(entry.master_value)
    value_has_first_letter = starts_with_letter?(entry.value)
    master_capitalized = starts_with_capitalized_letter?(entry.master_value)
    value_capitalized = starts_with_capitalized_letter?(entry.value)

    cond do
      value_capitalized === master_capitalized ->
        nil

      !master_has_first_letter or !value_has_first_letter ->
        nil

      value_capitalized ->
        ["", first_letter, rest] = String.split(entry.value, "", parts: 3)
        fixed_text = String.downcase(first_letter) <> rest
        to_message(entry, fixed_text)

      master_capitalized ->
        fixed_text = String.capitalize(entry.value)
        to_message(entry, fixed_text)

      true ->
        nil
    end
  end

  defp to_message(entry, fixed_text) do
    %Message{
      check: :first_letter_case,
      text: entry.value,
      replacement: %Replacement{value: fixed_text, label: fixed_text}
    }
  end

  defp starts_with_letter?(text) do
    Regex.match?(~r/^[\w]/i, text)
  end

  defp starts_with_capitalized_letter?(""), do: false

  defp starts_with_capitalized_letter?(text) do
    letter = entry_first_letter(text)
    capitalized_letter = String.capitalize(letter)
    downcased_letter = String.downcase(letter)

    capitalized_letter === letter and downcased_letter !== letter
  end

  defp entry_first_letter(nil), do: ""
  defp entry_first_letter(""), do: ""
  defp entry_first_letter(text), do: String.first(text)
end
