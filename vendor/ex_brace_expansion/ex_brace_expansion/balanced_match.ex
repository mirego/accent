defmodule ExBraceExpansion.BalancedMatch do

  def balanced(a, b, str), do: _balanced(a, b, str) |> format

  defp _balanced(a, b, str) do
    a_len = len(a)
    b_len = len(b)
    str_len = len(str)

    %{
      str: str,
      a: a,
      b: b,
      ended: false,
      i: 0,
      i_to_a_len: slice(str, 0, a_len),
      i_to_b_len: slice(str, 0, b_len),
      a_len: a_len,
      b_len: b_len,
      str_len: str_len, # need this for guard
      bal: 0,
      start: nil,
      finish: nil,
      segments: %{
        pre: "",
        body: "",
        post: ""
      }
    }
    |> get_segments
    |> deal_with_inbalance
  end

  defp get_segments(%{i: i, str_len: str_len} = state) when i == str_len do
    state
  end

  defp get_segments(%{i_to_a_len: i_to_a_len, a: a, start: start, bal: bal, i: i} = state) when i_to_a_len == a and start == nil do
    state
    |> move_to_next_i
    |> put_in([:bal], bal + 1)
    |> put_in([:start], i)
    |> get_segments
  end

  defp get_segments(%{i_to_a_len: i_to_a_len, a: a, bal: bal} = state) when i_to_a_len == a do
    state
    |> move_to_next_i
    |> put_in([:bal], bal + 1)
    |> get_segments
  end

  defp get_segments(%{i_to_b_len: i_to_b_len, b: b, start: start, bal: bal} = state) when i_to_b_len == b and start != nil and bal - 1 == 0 do
    %{i: i, str: str, start: start, a_len: a_len, b_len: b_len, str_len: str_len} = state

    segments = %{
      pre: slice(str, 0, start),
      body: (if i - start > 1, do: slice(str, (a_len + start)..i), else: ""),
      post: slice(str, (i + b_len)..str_len)
    }

    state
    |> put_in([:ended], true)
    |> put_in([:bal], bal - 1)
    |> put_in([:finish], i)
    |> put_in([:segments], segments)
  end

  defp get_segments(%{i_to_b_len: i_to_b_len, b: b, start: start, bal: bal} = state) when i_to_b_len == b and start != nil do
    state
    |> move_to_next_i
    |> put_in([:ended], true)
    |> put_in([:bal], bal - 1)
    |> get_segments
  end

  defp get_segments(state) do
    state
    |> move_to_next_i
    |> get_segments
  end

  defp deal_with_inbalance(%{bal: bal, ended: ended} = state) when bal != 0 and ended do
    %{a: a, b: b, str: str, a_len: a_len, str_len: str_len, start: start} = state

    _balanced(a, b, slice(str, start + a_len, str_len))
    |> reconstitute(str, start + a_len)
  end


  defp deal_with_inbalance(%{start: start, finish: finish}) when start == nil and finish == nil do
    nil
  end

  defp deal_with_inbalance(state) do
    state
  end

  defp reconstitute(state, _prev_str, _prev_start) when state == nil do
    nil
  end

  defp reconstitute(state, prev_str, prev_start) do
    %{start: start, finish: finish, segments: %{pre: pre}} = state

    state
    |> put_in([:start], start + prev_start)
    |> put_in([:finish], finish + prev_start)
    |> put_in([:segments, :pre], slice(prev_str, 0..prev_start) <> pre)
  end

  defp format(nil), do: nil

  defp format(%{start: start, finish: finish, segments: %{pre: pre, body: body, post: post}}) do
    %{
      start: start,
      finish: finish,
      pre: pre,
      body: body,
      post: post
    }
  end

  # helpers

  defp move_to_next_i(%{i: i, str: str, a_len: a_len, b_len: b_len} = state) do
    state
    |> put_in([:i], i + 1)
    |> put_in([:i_to_a_len], slice(str, i + 1, a_len))
    |> put_in([:i_to_b_len], slice(str, i + 1, b_len))
  end

  defp len(str), do: String.length(str)
  defp slice(str, start, len), do: String.slice(str, start, len)
  defp slice(str, start..finish), do: String.slice(str, start..(finish-1))

end
