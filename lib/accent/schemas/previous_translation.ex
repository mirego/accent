defmodule Accent.PreviousTranslation do
  @doc """
    ## Examples

    iex> Accent.PreviousTranslation.from_translation(nil)
    %{}
    iex> Accent.PreviousTranslation.from_translation(%{})
    %{}
    iex> Accent.PreviousTranslation.from_translation(%Accent.Translation{proposed_text: "a", corrected_text: "b", conflicted_text: "c", conflicted: true, removed: false, value_type: "text"})
    %{"proposed_text" => "a", "corrected_text" => "b", "conflicted_text" => "c", "conflicted" => true, "removed" => false, "value_type" => "text"}
    iex> Accent.PreviousTranslation.to_translation(%{"proposed_text" => "a", "corrected_text" => "b", "conflicted_text" => "c", "conflicted" => true, "removed" => false, "value_type" => "text"})
    %{proposed_text: "a", corrected_text: "b", conflicted_text: "c", conflicted: true, removed: false, value_type: "text"}
  """
  def from_translation(nil), do: %{}
  def from_translation(translation) when map_size(translation) == 0, do: %{}

  def from_translation(translation) do
    %{
      "proposed_text" => translation.proposed_text,
      "corrected_text" => translation.corrected_text,
      "conflicted_text" => translation.conflicted_text,
      "conflicted" => translation.conflicted,
      "removed" => translation.removed,
      "value_type" => translation.value_type
    }
  end

  def to_translation(translation) do
    %{
      proposed_text: translation["proposed_text"],
      corrected_text: translation["corrected_text"],
      conflicted_text: translation["conflicted_text"],
      conflicted: translation["conflicted"],
      removed: translation["removed"],
      value_type: translation["value_type"]
    }
  end
end
