defmodule ExBraceExpansion do
  @esc_slash "\0SLASH#{:random.uniform}\0"
  @esc_open "\0OPEN#{:random.uniform}\0"
  @esc_close "\0CLOSE#{:random.uniform}\0"
  @esc_comma "\0COMMA#{:random.uniform}\0"
  @esc_period "\0PERIOD#{:random.uniform}\0"

  @moduledoc """
  [Brace expansion](https://www.gnu.org/software/bash/manual/html_node/Brace-Expansion.html), as known from sh/bash, in Elixir. This is a port of [brace-expasion](https://github.com/juliangruber/brace-expansion) javascript project.

  """


  import ExBraceExpansion.BalancedMatch
  import ExBraceExpansion.ConcatMap

  @doc ~S"""
  expands the `str` into a list of patterns

  ## Examples
      iex> import ExBraceExpansion
      nil

      iex> expand("file-{a,b,c}.jpg")
      ["file-a.jpg", "file-b.jpg", "file-c.jpg"]

      iex> expand("-v{,,}")
      ["-v", "-v", "-v"]

      iex> expand("file{0..2}.jpg")
      ["file0.jpg", "file1.jpg", "file2.jpg"]

      iex> expand("file-{a..c}.jpg")
      ["file-a.jpg", "file-b.jpg", "file-c.jpg"]

      iex> expand("file{2..0}.jpg")
      ["file2.jpg", "file1.jpg", "file0.jpg"]

      iex> expand("file{0..4..2}.jpg")
      ["file0.jpg", "file2.jpg", "file4.jpg"]

      iex> expand("file-{a..e..2}.jpg")
      ["file-a.jpg", "file-c.jpg", "file-e.jpg"]

      iex> expand("file{00..10..5}.jpg")
      ["file00.jpg", "file05.jpg", "file10.jpg"]

      iex> expand("{{A..C},{a..c}}")
      ["A", "B", "C", "a", "b", "c"]

      iex> expand("ppp{,config,oe{,conf}}")
      ["ppp", "pppconfig", "pppoe", "pppoeconf"]

  """
  def expand(str) do
    if str == nil do
      []
    else
      _expand(escape_braces(str), true)
      |> Enum.map(fn val -> unescape_braces(val) end)
    end
  end

  defp _expand(str, is_top) do
    m = balanced("{", "}", str)

    done = m == nil || m.pre =~ ~r/\$$/
    is_numeric_sequence = if m, do: m.body =~ ~r/^-?\d+\.\.-?\d+(?:\.\.-?\d+)?$/, else: false
    is_alpha_sequence = if m, do: m.body =~ ~r/^[a-zA-Z]\.\.[a-zA-Z](?:\.\.-?\d+)?$/, else: false
    is_sequence = is_numeric_sequence || is_alpha_sequence
    is_options = if m, do: m.body =~ ~r/^(.*,)+(.+)?$/, else: false
    is_comma_and_brace = if m, do: m.body =~ ~r/,.*}/, else: false

    state = %{
      str: str,
      m: m,
      is_top: is_top,
      is_numeric_sequence: is_numeric_sequence,
      is_alpha_sequence: is_alpha_sequence,
      is_sequence: is_sequence,
      is_options: is_options,
      is_comma_and_brace: is_comma_and_brace,
      done: done,
      value: (if done, do: [str], else: nil)
    }

    state
    |> expand_step1
    |> expand_step2
    |> expand_step3
    |> expand_step4
    |> expand_step5
  end

  defp expand_step1(%{done: done} = state) when done, do: state

  defp expand_step1(%{is_sequence: is_sequence, is_options: is_options, is_comma_and_brace: is_comma_and_brace, m: m} = state) when not is_sequence and not is_options and is_comma_and_brace do
    state
    |> put_in([:done], true)
    |> put_in([:value], _expand(m.pre <> "{" <> m.body <> @esc_close <> m.post, false))
  end

  defp expand_step1(%{is_sequence: is_sequence, is_options: is_options, str: str} = state) when not is_sequence and not is_options do
    state
    |> put_in([:done], true)
    |> put_in([:value], [str])
  end

  defp expand_step1(%{is_sequence: is_sequence, m: m} = state) when is_sequence do
    state
    |> put_in([:n], Regex.split(~r/\.\./, m.body))
  end

  defp expand_step1(%{m: m} = state) do
    state
    |> put_in([:n], parse_comma_parts(m.body))
  end

  defp expand_step2(%{done: done} = state) when done, do: state

  defp expand_step2(%{is_sequence: is_sequence, n: n} = state) when not is_sequence and length(n) == 1 do
    state
    |> put_in([:n], _expand(hd(n), false) |> Enum.map(fn val -> embrace(val) end))
    |> expand_step2a
  end

  defp expand_step2(state), do: state

  defp expand_step2a(%{n: n, m: m} = state) when length(n) == 1 do
    post = if String.length(m.post) > 0, do: _expand(m.post, false), else: [""]
    value = Enum.map post, fn p ->
      m.pre <> hd(n) <> p
    end

    state
    |> put_in([:done], true)
    |> put_in([:value], value)
  end

  defp expand_step2a(state), do: state

  defp expand_step3(%{done: done} = state) when done, do: state

  defp expand_step3(%{m: m} = state) do
    state
    |> put_in([:pre], m.pre)
    |> put_in([:post], (if String.length(m.post) > 0, do: _expand(m.post, false), else: [""]))
  end

  defp expand_step4(%{done: done} = state) when done, do: state

  defp expand_step4(%{is_sequence: is_sequence, n: n, is_alpha_sequence: is_alpha_sequence} = state) when is_sequence do
    n_0 = Enum.at(n, 0)
    n_1 = Enum.at(n, 1)
    n_2 = Enum.at(n, 2)

    x = numeric(n_0)
    y = numeric(n_1)
    incr = if length(n) == 3, do: abs(numeric(n_2)), else: 1

    nn = for i <- x..y, rem(i - x, incr) == 0 do
      if is_alpha_sequence do
        get_alpha_character(i)
      else
        get_numeric_character(i, n, n_0, n_1)
      end
    end

    state
    |> put_in([:nn], nn)
  end

  defp expand_step4(%{n: n} = state) do
    state
    |> put_in([:nn], concat_map(n, fn val -> _expand(val, false) end))
  end

  defp expand_step5(%{done: done, value: value}) when done, do: value

  defp expand_step5(%{nn: nn, post: post, pre: pre, is_top: is_top, is_sequence: is_sequence}) do
    for x <- nn, y <- post do
      expansion = pre <> x <> y
      if not is_top or is_sequence or expansion do
        expansion
      else
        nil
      end
    end
  end

  # helpers

  defp escape_braces(str) do
    str
    |> String.split("\\\\") |> Enum.join(@esc_slash)
    |> String.split("\\{") |> Enum.join(@esc_open)
    |> String.split("\\}") |> Enum.join(@esc_close)
    |> String.split("\\,") |> Enum.join(@esc_comma)
    |> String.split("\\.") |> Enum.join(@esc_period)
  end

  defp unescape_braces(str) do
    str
    |> String.split(@esc_slash) |> Enum.join("\\")
    |> String.split(@esc_open) |> Enum.join("{")
    |> String.split(@esc_close) |> Enum.join("}")
    |> String.split(@esc_comma) |> Enum.join(",")
    |> String.split(@esc_period) |> Enum.join(".")
  end

  defp parse_comma_parts(str) when str == nil or str == "", do: [""]
  defp parse_comma_parts(str) do
    m = balanced("{", "}", str)

    if m == nil do
      str |> String.split(",")
    else
      p = m.pre |> String.split(",")
      p = List.update_at(p, length(p) - 1, fn val -> val <> "{" <> m.body <> "}" end)

      post_parts = parse_comma_parts(m.post)

      p = if m.post != "" do
        [post_parts_hd | post_parts_tail] = post_parts
        p = List.update_at(p, length(p) - 1, fn val -> val <> post_parts_hd end)
        p ++ post_parts_tail
      else
        p
      end

      [] ++ p
    end
  end

  defp numeric(val) do
    try do
      String.to_integer(val)
    rescue
      _ -> hd(to_charlist(val))
    end
  end

  defp embrace(str) do
    "{" <> str <> "}"
  end

  defp get_alpha_character(i) do
    c = to_string([i])
    if c == "\\", do: "", else: c
  end

  defp get_numeric_character(i, n, n_0, n_1) do
    c = to_string(i)
    pad = Enum.any? n, fn val -> val =~ ~r/^-?0\d/ end

    c = if pad do
      width = Enum.max([String.length(n_0), String.length(n_1)])
      need = width - String.length(c)
      if need > 0 do
        front_padding = Enum.join(Enum.map(0..(need-1), fn _ -> "0" end), "")
        if i < 0 do
          "-" <> front_padding <> String.slice(c, 1, String.length(c))
        else
          front_padding <> c
        end
      end
    else
      c
    end

    c
  end

end
