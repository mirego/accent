defmodule Movement.Comparers.MergeSmart do
  @behaviour Movement.Comparer

  alias Movement.Mappers.Operation, as: OperationMapper

  alias Movement.{
    Operation,
    TranslationComparer
  }

  @doc """
    ## Examples

    iex> translation = %Accent.Translation{key: "a", proposed_text: "foo", corrected_text: "bar"}
    iex> suggested_translation = %Movement.SuggestedTranslation{key: "a", text: "foo"}
    iex> Movement.Comparers.MergeSmart.compare(translation, suggested_translation) |> Map.get(:action)
    "noop"

    iex> translation = %Accent.Translation{key: "a", proposed_text: "bar", corrected_text: "foo"}
    iex> suggested_translation = %Movement.SuggestedTranslation{key: "a", text: "foo"}
    iex> Movement.Comparers.MergeSmart.compare(translation, suggested_translation) |> Map.get(:action)
    "update_proposed"

    iex> translation = %Accent.Translation{key: "a", proposed_text: "bar", corrected_text: "baz"}
    iex> suggested_translation = %Movement.SuggestedTranslation{key: "a", text: "foo"}
    iex> Movement.Comparers.MergeSmart.compare(translation, suggested_translation) |> Map.get(:action)
    "merge_on_corrected"

    iex> translation = %Accent.Translation{key: "a", proposed_text: "bar", corrected_text: "bar"}
    iex> suggested_translation = %Movement.SuggestedTranslation{key: "a", text: "foo"}
    iex> Movement.Comparers.MergeSmart.compare(translation, suggested_translation) |> Map.get(:action)
    "merge_on_proposed"

    iex> suggested_translation = %Movement.SuggestedTranslation{key: "a", text: "foo"}
    iex> Movement.Comparers.MergeSmart.compare(nil, suggested_translation) |> Map.get(:action)
    "noop"
  """
  def compare(nil, suggested_translation), do: %Operation{action: "noop", key: suggested_translation.key}

  def compare(translation, suggested_translation) do
    suggested_translation = %{suggested_translation | revision_id: translation.revision_id}

    case TranslationComparer.compare(translation, suggested_translation.text) do
      {"update_proposed", new_text} ->
        suggested_translation = %{suggested_translation | text: new_text}

        OperationMapper.map("update_proposed", translation, suggested_translation)

      {"conflict_on_proposed", new_text} ->
        suggested_translation = %{suggested_translation | text: new_text}

        OperationMapper.map("merge_on_proposed", translation, suggested_translation)

      {"conflict_on_corrected", new_text} ->
        suggested_translation = %{suggested_translation | text: new_text}

        OperationMapper.map("merge_on_corrected", translation, suggested_translation)

      {_action, text} ->
        %Operation{action: "noop", key: translation.key, text: text}
    end
  end
end
