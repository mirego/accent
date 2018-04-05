defmodule Accent.Utils.SecureRandom do
  use Bitwise

  @default_length 16

  @doc """
  Returns random Base64 encoded string.
  ## Examples

      iex> Accent.Utils.SecureRandom.base64
      "rm/JfqH8Y+Jd7m5SHTHJoA=="
      iex> Accent.Utils.SecureRandom.base64(8)
      "2yDtUyQ5Xws="
  """
  def base64(length \\ @default_length) do
    length
    |> random_bytes()
    |> :base64.encode_to_string()
    |> to_string
  end

  def urlsafe_base64(length \\ @default_length) do
    length
    |> base64()
    |> String.replace(~r/[\n\=]/, "")
    |> String.replace(~r/\+/, "-")
    |> String.replace(~r/\//, "_")
  end

  @doc """
  Returns random bytes.

  ## Examples
      iex> Accent.Utils.SecureRandom.random_bytes
      <<202, 104, 227, 197, 25, 7, 132, 73, 92, 186, 242, 13, 170, 115, 135, 7>>
      iex> Accent.Utils.SecureRandom.random_bytes(8)
      <<231, 123, 252, 174, 156, 112, 15, 29>>
  """
  def random_bytes(length \\ @default_length) do
    :crypto.strong_rand_bytes(length)
  end
end
