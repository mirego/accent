defmodule ExMinimatch.Compiler do
  import Map, only: [merge: 2]
  import ExBraceExpansion
  import ExMinimatch.Helper

  @qmark ExMinimatcher.qmark
  @globstar ExMinimatcher.globstar
  @star ExMinimatcher.star
  @re_specials ExMinimatcher.re_specials
  @slash_split ExMinimatcher.slash_split

  def compile_matcher(glob, options) do
    {regex_parts_set, negate} = if short_circuit_comments(glob, options) do
      {[], false}
    else
      make_re(glob, options)
    end

    %ExMinimatcher{
      glob: glob,
      pattern: regex_parts_set,
      negate: negate,
      options: options
    }
  end

  def short_circuit_comments(pattern, options) do
    (not options[:nocomment] and String.first(pattern) == "#") or pattern == ""
  end

  def make_re(pattern, options) do
    debug {"make_re", pattern, options}, options

    # step 1 figure out negate
    {negate, pattern} = parse_negate(pattern, options)
    debug {"make_re step 1", negate, pattern}, options

    # step 2 expand braces
    expanded_pattern_set = expand_braces(pattern, options)
    debug {"make_re step 2", expanded_pattern_set}, options

    # step 3: now we have a set, so turn each one into a series of path-portion
    # matching patterns.
    # These will be regexps, except in the case of "**", which is
    # set to the GLOBSTAR object for globstar behavior,
    # and will not contain any / characters

    # step 3a split slashes
    glob_parts_set = Enum.map expanded_pattern_set, fn (expanded_pattern) ->
      Regex.split(@slash_split, expanded_pattern)
    end
    debug {"make_re step 3a", glob_parts_set}, options

    # step 3b  glob -> regex
    regex_parts_set = Enum.map glob_parts_set, fn glob_parts ->
      Enum.map glob_parts, fn glob_part ->
        parse_glob_to_re(glob_part, options)
      end
    end
    debug {"make_re step 3b", regex_parts_set}, options

    # step 4 filter out everything that didn't compile properly.
    regex_parts_set = Enum.filter regex_parts_set, fn regex_parts ->
      Enum.all? regex_parts, fn regexp -> regexp != false end
    end
    debug {"make_re step 4", regex_parts_set}, options

    {regex_parts_set, negate}
  end

  def expand_braces(pattern, options) do
    if options[:nobrace] or not (pattern =~ ~r/\{.*\}/) do
      [pattern]
    else
      expand(pattern)
    end
  end

  def parse_negate(pattern, %{nonegate: nonegate}) when nonegate, do: {false, pattern}

  def parse_negate(pattern, _options) do
    {_, negate, negateOffset} = Enum.reduce 0..(len(pattern) - 1), {true, false, 0}, fn i, {previous_negate, negate, negateOffset} ->
      cond do
        not previous_negate ->
          {previous_negate, negate, negateOffset}
        at(pattern, i) == "!" ->
          {previous_negate, not negate, negateOffset + 1}
        true ->
          {false, negate, negateOffset}
      end
    end

    if (negateOffset > 0) do
      {negate, slice(pattern, negateOffset, len(pattern))}
    else
      {negate, pattern}
    end
  end

  # parse a component of the expanded set.
  # At this point, no pattern may contain "/" in it
  # so we're going to return a 2d array, where each entry is the full
  # pattern, split on '/', and then turned into a regular expression.
  # A regexp is made at the end which joins each array with an
  # escaped /, and another full one which joins each regexp with |.
  #
  # Following the lead of Bash 4.1, note that "**" only has special meaning
  # when it is the *only* thing in a path portion.  Otherwise, any series
  # of * is equivalent to a single *.
  def parse_glob_to_re(glob_pattern, %{noglobstar: noglobstar}) when glob_pattern == "**" and not noglobstar, do: @globstar

  def parse_glob_to_re(glob_pattern, _options) when glob_pattern == "", do: ""

  def parse_glob_to_re(glob_pattern, options, is_sub \\ false) do
    %{
      pattern: glob_pattern,
      pattern_len: len(glob_pattern),
      i: 0,
      c: at(glob_pattern, 0),
      re: "",
      has_magic: options[:nocase],
      escaping: false,
      pattern_list_stack: [],
      pl_type: nil,
      state_char: "",
      in_class: false,
      re_class_start: -1,
      class_start: -1,
      pattern_start: (if String.first(glob_pattern) == ".", do: "", else: (if options[:dot], do: "(?!(?:^|\\\/)\\.{1,2}(?:$|\\\/))", else: "(?!\\.)")),
      is_sub: is_sub,
      options: options,
      failed: false
    }
    |> parse
    |> tap(fn state -> debug {"parse", state}, state[:options] end)
    |> handle_open_class
    |> tap(fn state -> debug {"handle_open_class", state}, state[:options] end)
    |> handle_weird_end
    |> tap(fn state -> debug {"handle_weird_end", state}, state[:options] end)
    |> handle_trailing_things
    |> tap(fn state -> debug {"handle_trailing_things", state}, state[:options] end)
    |> handle_dot_start
    |> tap(fn state -> debug {"handle_dot_start", state}, state[:options] end)
    |> finish_parse
  end

  # terminal, should return something rather than recurs
  def parse(%{failed: failed} = state) when failed, do: state

  def parse(%{i: i, pattern_len: pattern_len} = state) when i == pattern_len, do: state

  def parse(%{c: c, re: re, escaping: escaping} = state) when escaping and c in @re_specials do
    state
    |> merge(%{
        re: re <> "\\" <> c,
        escaping: false
      })
    |> continue
  end

  def parse(%{c: "/"} = state), do: merge(state, %{failed: true})

  def parse(%{c: "\\"} = state) do
    state
    |> clear_state_char()
    |> merge(%{escaping: true})
    |> continue
  end

  def parse(%{c: c, in_class: in_class, i: i, class_start: class_start, re: re} = state) when c in ["?", "*", "+", "@", "!"] and in_class do
    c = if c == "!" and i == class_start + 1, do: "^", else: c
    state
    |> merge(%{re: re <> c})
    |> continue
  end

  def parse(%{c: c, options: %{noext: noext}} = state) when c in ["?", "*", "+", "@", "!"] do
    state
    |> clear_state_char()
    |> merge(%{state_char: c})
    |> transform(fn state -> if noext, do: clear_state_char(state), else: state end)
    |> continue
  end

  def parse(%{c: c, in_class: in_class, re: re} = state) when c == "(" and in_class do
    state
    |> merge(%{re: re <> "("})
    |> continue
  end

  def parse(%{c: c, state_char: state_char, re: re} = state) when c == "(" and state_char == "" do
    state
    |> merge(%{re: re <> "\\("})
    |> continue
  end

  def parse(%{c: c, state_char: state_char, pattern_list_stack: pattern_list_stack, re: re, i: i} = state) when c == "(" do
    state
    |> merge(%{
        pl_type: state_char,
        pattern_list_stack: [%{type: state_char, start: i - 1, re_start: len(re)} | pattern_list_stack],
        re: re <> (if state_char == "!", do: "(?:(?!", else: "(?:"),
        state_char: ""
      })
    |> continue
  end

  def parse(%{c: c, in_class: in_class, pattern_list_stack: pattern_list_stack, re: re} = state) when c == ")" and (in_class or length(pattern_list_stack) == 0) do
    state
    |> merge(%{re: re <> "\\)"})
    |> continue
  end

  def parse(%{c: c} = state) when c == ")" do
    state
    |> clear_state_char()
    |> merge(%{has_magic: true})
    |> transform(fn %{pattern_list_stack: pattern_list_stack, re: re} = state ->
      new_re = re <> ")"

      [pattern_list_stack_hd | new_pattern_list_stack] = pattern_list_stack

      new_pl_type = pattern_list_stack_hd[:type]

      new_re = cond do
        new_pl_type == "!" ->
          new_re <> "[^/]*?)"
        new_pl_type in ["*", "?", "+"] ->
          new_re <> new_pl_type
        true ->
          new_re
      end

      state
      |> merge(%{
          re: new_re,
          pl_type: new_pl_type,
          pattern_list_stack: new_pattern_list_stack
        })
    end)
    |> continue
  end

  def parse(%{c: c, in_class: in_class, pattern_list_stack: pattern_list_stack, escaping: escaping, re: re} = state) when c == "|" and (in_class or length(pattern_list_stack) == 0 or escaping) do
    state
    |> merge(%{
        re: re <> "\\|",
        escaping: false
      })
    |> continue
  end

  def parse(%{c: c} = state) when c == "|" do
    state
    |> clear_state_char()
    |> transform(fn %{re: re} = state ->
        state
        |> merge(%{re: re <> "|"})
      end)
    |> continue
  end

  def parse(%{c: c, in_class: in_class} = state) when c == "[" and in_class do
    state
    |> clear_state_char()
    |> transform(fn %{re: re} = state ->
        state
        |> merge(%{re: re <> "\\" <> c})
      end)
    |> continue
  end

  def parse(%{c: c, i: i} = state) when c == "[" do
    state
    |> clear_state_char()
    |> transform(fn %{re: re} = state ->
        state
        |> merge(%{
            in_class: true,
            class_start: i,
            re_class_start: len(re),
            re: re <> c
          })
      end)
    |> continue
  end

  def parse(%{c: c, re: re, in_class: in_class, i: i, class_start: class_start} = state) when c == "]" and (i == class_start + 1 or not in_class) do
    state
    |> merge(%{
        re: re <> "\\" <> c,
        escaping: false
      })
    |> continue
  end

  def parse(%{c: c, re: re, in_class: in_class} = state) when c == "]" and in_class do
    %{
      pattern: pattern,
      class_start: class_start,
      i: i,
      re_class_start: re_class_start,
      has_magic: has_magic
    } = state

    cs = slice(pattern, (class_start + 1)..(i - 1))

    state_changes = case Regex.compile("[" <> cs <> "]") do
      {:error, _} ->
        {sub_re, sub_has_magic} = parse_glob_to_re(cs, state[:options], true)

        %{
          re: slice(re, 0, re_class_start) <> "\\[" <> sub_re <> "\\]",
          has_magic: has_magic or sub_has_magic,
          in_class: false
        }
      _ ->
        %{
          re: re <> c,
          has_magic: true,
          in_class: false
        }
    end

    state
    |> merge(state_changes)
    |> continue
  end

  def parse(%{escaping: escaping, c: c} = state) when escaping do
    state
    |> clear_state_char()
    |> transform(fn %{re: re} = state ->
        state
        |> merge(%{
            escaping: false,
            re: re <> c
          })
      end)
    |> continue
  end

  def parse(%{c: c, in_class: in_class} = state) when c in @re_specials and not (c == "^" and in_class) do
    state
    |> clear_state_char()
    |> transform(fn %{re: re} = state ->
        state
        |> merge(%{
            re: re <> "\\" <> c
          })
      end)
    |> continue
  end

  def parse(%{c: c} = state) do
    state
    |> clear_state_char()
    |> transform(fn %{re: re} = state ->
        state
        |> merge(%{
            re: re <> c
          })
      end)
    |> continue
  end

  # handle the case where we left a class open.
  # "[abc" is valid, equivalent to "\[abc"
  def handle_open_class(%{failed: failed} = state) when failed, do: state

  def handle_open_class(%{in_class: in_class} = state) when in_class do
    %{
      pattern: pattern,
      re: re,
      class_start: class_start,
      re_class_start: re_class_start,
      has_magic: has_magic
    } = state

    cs = slice(pattern, class_start + 1, len(pattern))

    {sub_re, sub_has_magic} = parse_glob_to_re(cs, state[:options], true)

    state
    |> merge(%{
        re: slice(re, 0, re_class_start) <> "\\[" <> sub_re,
        has_magic: has_magic or sub_has_magic
      })
  end

  def handle_open_class(state), do: state

  # handle the case where we had a +( thing at the *end*
  # of the pattern.
  # each pattern list stack adds 3 chars, and we need to go through
  # and escape any | chars that were passed through as-is for the regexp.
  # Go through and escape them, taking care not to double-escape any
  # | chars that were already escaped.
  def handle_weird_end(%{failed: failed} = state) when failed, do: state

  def handle_weird_end(%{pattern_list_stack: pattern_list_stack, re: re} = state) when length(pattern_list_stack) > 0 do
    debug {"handle_weird_end", pattern_list_stack}, state[:options]

    [pl | new_pattern_list_stack] = pattern_list_stack

    tail = slice(re, pl[:re_start] + 3, len(re))

    tail = Regex.replace ~r/((?:\\{2})*)(\\?)\|/, tail, fn (_, a, b) ->
      if b == "" do
        a <> a <> "\\" <> "|"
      else
        a <> a <> b <> "|"
      end
    end

    t = case pl[:type] do
      "*" -> @star
      "?" -> @qmark
      _ -> "\\" <> pl[:type]
    end

    state
    |> merge(%{
        has_magic: true,
        re: slice(re, 0, pl[:re_start]) <> t <> "\\(" <> tail,
        pattern_list_stack: new_pattern_list_stack
      })
    |> handle_weird_end
  end

  def handle_weird_end(state), do: state


  def handle_trailing_things(%{failed: failed} = state) when failed, do: state

  def handle_trailing_things(%{escaping: escaping, re: re} = state) when escaping do
    debug {"handle_trailing_things", escaping, re}, state[:options]

    state
    |> clear_state_char()
    |> merge(%{
        re: re <> "\\\\"
      })
  end

  def handle_trailing_things(state), do: clear_state_char(state)


  def handle_dot_start(%{failed: failed} = state) when failed, do: state

  def handle_dot_start(%{re: re, has_magic: has_magic, pattern_start: pattern_start} = state) do
    debug {"handle_dot_start", re, has_magic, pattern_start}, state[:options]

    add_pattern_start = String.first(re) in [".", "[", "("]

    new_re = if re != "" and has_magic, do: "(?=.)" <> re, else: re

    new_re = if add_pattern_start, do: pattern_start <> new_re, else: new_re

    state
    |> merge(%{ re: new_re })
  end


  def finish_parse(%{failed: failed}) when failed, do: false

  def finish_parse(%{is_sub: is_sub, re: re, has_magic: has_magic}) when is_sub, do: {re, has_magic}

  # skip the regexp for non-magical patterns
  # unescape anything in it, though, so that it'll be
  # an exact match against a file etc.
  def finish_parse(%{has_magic: has_magic, pattern: pattern}) when not has_magic, do: glob_unescape(pattern)

  def finish_parse(%{options: options, re: re}) do
    flags = if options[:nocase], do: "i", else: ""

    case Regex.compile("^#{re}$", flags) do
      {:ok, result} ->
        # {result, re}
        result
      _ ->
        false
    end
  end

  def glob_unescape(s) do
    Regex.replace(~r/\\(.)/, s, fn _, a -> a end)
  end

  def regex_escape(s) do
    Regex.replace(~r/[-[\]{}()*+?.,\\^$|#\s]/, s, "\\\\\\0")
  end

  def clear_state_char(%{state_char: state_char} = state) when state_char == "", do: state

  def clear_state_char(%{state_char: state_char, re: re} = state) do
    state
    |> merge(case state_char do
        "*" ->
          %{
            re: re <> @star,
            has_magic: true,
            state_char: ""
          }
        "?" ->
          %{
            re: re <> @qmark,
            has_magic: true,
            state_char: ""
          }
        _ ->
          %{
            re: re <> "\\" <> state_char,
            state_char: ""
          }
      end)
  end

  def move_to_next(%{i: i, pattern: pattern} = state) do
    state
    |> merge(%{
        i: i + 1,
        c: at(pattern, i + 1)
      })
  end

  def continue(state) do
    state
    |> tap(fn %{options: options} = state -> info({"continue", state}, options) end)
    |> move_to_next
    |> parse
  end
end
