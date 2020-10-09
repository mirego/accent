defmodule ExMinimatch.Matcher do
  import Map, only: [merge: 2]
  import ExMinimatch.Helper

  @globstar ExMinimatcher.globstar
  @slash_split ExMinimatcher.slash_split

  def match_file(file, %ExMinimatcher{pattern: regex_parts_set, negate: negate, options: options}) do
    info {"match_file", file, regex_parts_set, negate, options}, options

    split_file_parts = Regex.split(@slash_split, file)
    basename = Path.basename(file)

    found = Enum.any? regex_parts_set, fn regex_parts ->
      file_parts = if options[:match_base] and length(regex_parts) == 1, do: [basename], else: split_file_parts

      match_regex_parts(regex_parts, file_parts, options)
    end

    if found, do: not negate, else: negate
  end

  def match_regex_parts(regex_parts, file_parts, options) do
    debug {"match_regex_parts", file_parts, regex_parts, options}, options

    %{
      file_parts: file_parts,
      regex_parts: regex_parts,
      fi: 0,
      ri: 0,
      fl: len(file_parts),
      rl: len(regex_parts),
      f: at(file_parts, 0),
      r: at(regex_parts, 0),
      options: options
    }
    |> match_regex_parts
  end

  # ran out of regex and file parts at the same time, which is a match
  def match_regex_parts(%{fi: fi, ri: ri, fl: fl, rl: rl}) when fi == fl and ri == rl, do: true

  # ran out of file parts but still regex left, no match
  def match_regex_parts(%{fi: fi, fl: fl}) when fi == fl, do: false

  # ran out of pattern but still file parts left
  def match_regex_parts(%{fi: fi, ri: ri, fl: fl, rl: rl} = state) when ri == rl do
    # is match only if the file part is the last one and it is ""
    fi == fl - 1 && at(state[:file_parts], fi) == ""
  end

  # current regex is a **, but it's also the last regex, and since ** matches
  # everything, true unless dots are found (except if dot: true is requested)
  def match_regex_parts(%{r: r, ri: ri, rl: rl, fi: fi, fl: fl, file_parts: file_parts, options: options}) when r == @globstar and ri + 1 == rl do
    dot_found = Enum.find fi..(fl-1), fn i ->
      file_part_i = at(file_parts, i)

      file_part_i in [".", ".."] or (not options[:dot] and String.first(file_part_i) == ".")
    end

    dot_found == nil
  end

  # current regex is a **, and not the last regex, then try swallow file parts
  # match on the next pattern
  def match_regex_parts(%{r: r, fi: fi} = state) when r == @globstar do
    swallow_and_match_next_regex_part(state, fi)
  end

  def match_regex_parts(%{f: f, r: r, fi: fi, ri: ri, file_parts: file_parts, regex_parts: regex_parts, options: options} = state) do
    hit = if is_binary(r) do
      if options[:nocase], do: String.downcase(f) == String.downcase(r), else: f == r
    else
      Regex.match?(r, f)
    end

    if not hit do
      false
    else
      state
      |> merge(%{
          fi: fi + 1,
          ri: ri + 1,
          f: at(file_parts, fi + 1),
          r: at(regex_parts, ri + 1)
        })
      |> match_regex_parts
    end
  end

  def swallow_and_match_next_regex_part(%{fl: fl} = state, fr) when fr < fl do
    %{
      ri: ri,
      rl: rl,
      file_parts: file_parts,
      regex_parts: regex_parts,
      options: %{
        dot: dot
      } = options
    } = state

    rest_of_regex_parts_from_next = slice(regex_parts, ri + 1, rl)

    rest_of_file_parts = slice(file_parts, fr, fl)

    swallowee = at(file_parts, fr)

    cond do
      match_regex_parts(rest_of_regex_parts_from_next, rest_of_file_parts, options) ->
        true
      swallowee in [".", ".."] or (String.starts_with?(swallowee, ".") and not dot) ->
        swallow_and_match_next_regex_part(state, fl) # recurse to terminate
      true ->
        swallow_and_match_next_regex_part(state, fr + 1) # recurse to next file part
    end
  end

  def swallow_and_match_next_regex_part(%{fl: fl}, fr) when fl == fr, do: false
end
