defmodule Movement.Builders.TranslationCorrectConflict do
  @moduledoc false
  @behaviour Movement.Builder

  alias Movement.Builders.TranslationTextChange

  def build(context), do: TranslationTextChange.build(context, "correct_conflict")
end
