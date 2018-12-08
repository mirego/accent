defmodule Accent.Utils.SecureRandom do
  @moduledoc """
  Returns random Base64 encoded string.
  ## Examples

      iex> Accent.Utils.SecureRandom.urlsafe_base64
      "rmJfqH8YJd7m5SHTHJoA"
      iex> Accent.Utils.SecureRandom.urlsafe_base64(8)
      "FOrHdEaqSOU"
  """

  def urlsafe_base64(length) do
    length
    |> :crypto.strong_rand_bytes()
    |> :base64.encode_to_string()
    |> to_string
    |> String.replace(~r/[\n\=]/, "")
    |> String.replace(~r/\+/, "-")
    |> String.replace(~r/\//, "_")
  end
end
