defmodule Accent.CleanContext do
  @specials [
    <<255, 240>>,
    <<255, 241>>,
    <<255, 242>>,
    <<255, 243>>,
    <<255, 244>>,
    <<255, 245>>,
    <<255, 246>>,
    <<255, 247>>,
    <<255, 248>>,
    <<255, 240>>,
    <<255, 16>>,
    <<255, 17>>,
    <<255, 18>>,
    <<255, 19>>,
    <<255, 20>>,
    <<255, 250>>,
    <<255, 251>>,
    <<255, 252>>,
    <<255, 254>>,
    <<255, 255>>
  ]

  @replacement_character "�"

  def unicode_only(string, new_string \\ "")

  def unicode_only(<<head::binary-size(2)>> <> tail, new_string)
      when head in @specials do
    unicode_only(tail, @replacement_character <> new_string)
  end

  def unicode_only(<<head::binary-size(1)>> <> tail, new_string) do
    printable_head? = String.printable?(head)
    printable_tail? = String.printable?(tail)
    cond do
      printable_head? and printable_tail? ->
        String.reverse(new_string) <> head <> tail
      printable_head? ->
        unicode_only(tail, head <> new_string)
      true ->
        unicode_only(tail, new_string)
    end
  end

  def unicode_only("", new_string), do: String.reverse(new_string)
end
