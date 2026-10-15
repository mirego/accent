defmodule Movement.Builders.TranslationUncorrectConflict do
  @moduledoc false
  @behaviour Movement.Builder

  alias Movement.Builders.TranslationTextChange

  def build(context), do: TranslationTextChange.build(context, "uncorrect_conflict")
end
