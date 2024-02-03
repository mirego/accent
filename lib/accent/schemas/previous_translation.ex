defmodule Accent.PreviousTranslation do
  @moduledoc false
  use Ecto.Schema

  @fields ~w(
    proposed_text
    corrected_text
    conflicted_text
    conflicted
    translated
    removed
    value_type
    placeholders
  )a

  @primary_key false
  embedded_schema do
    field(:proposed_text, :string, default: "")
    field(:corrected_text, :string, default: "")
    field(:conflicted_text, :string, default: "")
    field(:conflicted, :boolean, default: false)
    field(:removed, :boolean, default: false)
    field(:translated, :boolean, default: false)
    field(:value_type, :string, default: "string")
    field(:placeholders, {:array, :string}, default: [])
  end

  @doc """
    ## Examples

    iex> Accent.PreviousTranslation.from_translation(nil)
    %Accent.PreviousTranslation{}
    iex> Accent.PreviousTranslation.from_translation(%Accent.Translation{translated: true, proposed_text: "a", corrected_text: "b", conflicted_text: "c", conflicted: true, removed: false, value_type: "string", placeholders: ["foo"]})
    %Accent.PreviousTranslation{translated: true, proposed_text: "a", corrected_text: "b", conflicted_text: "c", conflicted: true, removed: false, value_type: "string", placeholders: ["foo"]}
  """
  def from_translation(nil), do: from_translation(%{})

  def from_translation(translation) do
    translation
    |> Map.take(@fields)
    |> then(&struct(__MODULE__, &1))
  end
end
