defmodule Accent.PrettyFloat do
  @moduledoc """
  Pretty prints a float into either a float or an integer.
  If the float ends with .0, it returns an integer.

  This is used to have a pretty percentage output.

  ## Examples

    iex> Accent.PrettyFloat.convert(2.0)
    2
    iex> Accent.PrettyFloat.convert(2.2)
    2.2
    iex> Accent.PrettyFloat.convert(28)
    28
  """

  def convert(float) when trunc(float) == float, do: trunc(float)
  def convert(float), do: float
end
