defmodule Movement.Comparers.MergeForce do
  @moduledoc false
  @behaviour Movement.Comparer

  alias Movement.Mappers.Operation, as: OperationMapper
  alias Movement.Operation
  alias Movement.TranslationComparer

  @doc """
    ## Examples

    iex> translation = %Accent.Translation{key: "a", proposed_text: "foo", corrected_text: "bar"}
    iex> suggested_translation = %Movement.SuggestedTranslation{key: "a", text: "foo"}
    iex> Movement.Comparers.MergeForce.compare(translation, suggested_translation) |> Map.get(:action)
    "merge_on_corrected_force"

    iex> translation = %Accent.Translation{key: "a", proposed_text: "bar", corrected_text: "foo"}
    iex> suggested_translation = %Movement.SuggestedTranslation{key: "a", text: "foo"}
    iex> Movement.Comparers.MergeForce.compare(translation, suggested_translation) |> Map.get(:action)
    "noop"

    iex> translation = %Accent.Translation{key: "a", proposed_text: "bar", corrected_text: "baz"}
    iex> suggested_translation = %Movement.SuggestedTranslation{key: "a", text: "foo"}
    iex> Movement.Comparers.MergeForce.compare(translation, suggested_translation) |> Map.get(:action)
    "merge_on_corrected_force"

    iex> translation = %Accent.Translation{key: "a", proposed_text: "bar", corrected_text: "bar"}
    iex> suggested_translation = %Movement.SuggestedTranslation{key: "a", text: "foo"}
    iex> Movement.Comparers.MergeForce.compare(translation, suggested_translation) |> Map.get(:action)
    "merge_on_proposed_force"

    iex> suggested_translation = %Movement.SuggestedTranslation{key: "a", text: "foo"}
    iex> Movement.Comparers.MergeForce.compare(nil, suggested_translation) |> Map.get(:action)
    "noop"
  """
  def compare(nil, suggested_translation), do: %Operation{action: "noop", key: suggested_translation.key}

  def compare(translation, suggested_translation) do
    suggested_translation = %{suggested_translation | revision_id: translation.revision_id}

    case TranslationComparer.compare(translation, suggested_translation.text) do
      {action, _text} when action in ~w(conflict_on_corrected autocorrect) ->
        OperationMapper.map("merge_on_corrected_force", translation, suggested_translation)

      {"conflict_on_proposed", _text} ->
        OperationMapper.map("merge_on_proposed_force", translation, suggested_translation)

      {_action, text} ->
        %Operation{action: "noop", key: translation.key, text: text}
    end
  end
end
