defmodule ExMinimatcher do
  defstruct glob: "",
            pattern: [],
            negate: false,
            options: %{
              dot: false,
              nocase: false,
              match_base: false,
              nonegate: false,
              noext: false,
              noglobstar: false,
              nocomment: false,
              nobrace: false,
              log: nil
            }

  @qmark "[^/]"
  def qmark, do: @qmark

  @globstar :globstar
  def globstar, do: @globstar

  # * => any number of characters
  @star "#{@qmark}*?"
  def star, do: @star

  # ** when dots are allowed.  Anything goes, except .. and .
  # not (^ or / followed by one or two dots followed by $ or /),
  # followed by anything, any number of times.
  @two_star_dot "(?:(?!(?:\\\/|^)(?:\\.{1,2})($|\\\/)).)*?"
  def two_star_dot, do: @two_star_dot

  # not a ^ or / followed by a dot,
  # followed by anything, any number of times.
  @two_star_no_dot "(?:(?!(?:\\\/|^)\\.).)*?"
  def two_star_no_dot, do: @two_star_no_dot

  # characters that need to be escaped in RegExp.
  @re_specials [ "(", ")", ".", "*", "{", "}", "+", "?", "[", "]", "^", "$", "\\", "!" ]
  def re_specials, do: @re_specials

  @slash_split ~r/\/+/
  def slash_split, do: @slash_split
end
