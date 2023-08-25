defmodule Accent.EmailViewStyleHelper do
  @moduledoc false
  @default_link_styles [
    "font-family": ~s(Helvetica, Arial, sans-serif),
    color: "#1ecd8d",
    "text-decoration": "none"
  ]

  @default_paragraph_styles [
    margin: "20px 0",
    color: "#7b7b7b",
    "font-family": ~s(Helvetica, Arial, sans-serif),
    "line-height": "1.5"
  ]

  def style(styles \\ []) do
    format_styles(styles, [])
  end

  def link_style(styles \\ []) do
    format_styles(styles, @default_link_styles)
  end

  def paragraph_style(styles \\ []) do
    format_styles(styles, @default_paragraph_styles)
  end

  defp format_styles(default_styles, styles) do
    default_styles
    |> Enum.concat(styles)
    |> Enum.uniq_by(fn {key, _value} -> key end)
    |> Enum.map_join("; ", fn {key, value} -> "#{key}: #{value}" end)
  end
end
