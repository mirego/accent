defmodule Movement.Comparers.SyncSmart do
  @moduledoc false
  @behaviour Movement.Comparer

  alias Movement.Mappers.Operation, as: OperationMapper
  alias Movement.Operation
  alias Movement.TranslationComparer

  @doc """
    ## Examples

    iex> translation = %Accent.Translation{key: "a", proposed_text: "foo", corrected_text: "bar"}
    iex> suggested_translation = %Movement.SuggestedTranslation{key: "a", text: "foo"}
    iex> Movement.Comparers.SyncSmart.compare(translation, suggested_translation).action
    "autocorrect"

    iex> translation = %Accent.Translation{key: "a", proposed_text: "bar", corrected_text: "foo"}
    iex> suggested_translation = %Movement.SuggestedTranslation{key: "a", text: "foo"}
    iex> Movement.Comparers.SyncSmart.compare(translation, suggested_translation).action
    "update_proposed"

    iex> translation = %Accent.Translation{key: "a", proposed_text: "bar", corrected_text: "baz"}
    iex> suggested_translation = %Movement.SuggestedTranslation{key: "a", text: "foo"}
    iex> Movement.Comparers.SyncSmart.compare(translation, suggested_translation).action
    "conflict_on_corrected"

    iex> translation = %Accent.Translation{key: "a", proposed_text: "bar", corrected_text: "baz"}
    iex> suggested_translation = %Movement.SuggestedTranslation{key: "a", text: "foo"}
    iex> Movement.Comparers.SyncSmart.compare(translation, suggested_translation).text
    "foo"
  """
  def compare(translation, suggested_translation) do
    case TranslationComparer.compare(translation, suggested_translation.text) do
      {action, text} when action === "autocorrect" ->
        %Operation{action: action, key: translation.key, text: text}

      {action, text} ->
        suggested_translation = %{suggested_translation | text: text}

        OperationMapper.map(action, translation, suggested_translation)
    end
  end
end
