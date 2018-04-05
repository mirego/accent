defmodule Movement.Comparers.Sync do
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
    iex> Movement.Comparers.Sync.compare(translation, suggested_translation) |> Map.get(:action)
    "autocorrect"

    iex> translation = %Accent.Translation{key: "a", proposed_text: "bar", corrected_text: "foo"}
    iex> suggested_translation = %Movement.SuggestedTranslation{key: "a", text: "foo"}
    iex> Movement.Comparers.Sync.compare(translation, suggested_translation) |> Map.get(:action)
    "update_proposed"

    iex> translation = %Accent.Translation{key: "a", proposed_text: "bar", corrected_text: "baz"}
    iex> suggested_translation = %Movement.SuggestedTranslation{key: "a", text: "foo"}
    iex> Movement.Comparers.Sync.compare(translation, suggested_translation) |> Map.get(:action)
    "conflict_on_corrected"

    iex> translation = %Accent.Translation{key: "a", proposed_text: "bar", corrected_text: "baz"}
    iex> suggested_translation = %Movement.SuggestedTranslation{key: "a", text: "foo"}
    iex> Movement.Comparers.Sync.compare(translation, suggested_translation) |> Map.get(:text)
    "foo"
  """
  def compare(translation, suggested_translation) do
    case TranslationComparer.compare(translation, suggested_translation.text) do
      {action, _text} when action in ~w(autocorrect) ->
        %Operation{action: action, key: translation.key}

      {action, text} ->
        suggested_translation = %{suggested_translation | text: text}

        OperationMapper.map(action, translation, suggested_translation)
    end
  end
end
