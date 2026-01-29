defmodule Movement.Builders.VersionCopyOnUpdate do
  @moduledoc """
  Shared logic for copying translation updates from versioned translations
  to their source (latest) translations when the version has `copy_on_update_translation` enabled.
  """

  alias Accent.Repo
  alias Accent.Version
  alias Movement.Mappers.Operation, as: OperationMapper
  alias Movement.Mappers.ValueType

  @doc """
  Creates an operation to copy the translation update to the source translation
  if the translation belongs to a version with `copy_on_update_translation` enabled.

  Returns nil if the feature is not enabled or the translation has no version.
  """
  @spec maybe_copy_to_latest_version(Accent.Translation.t(), String.t(), String.t()) ::
          Movement.Operation.t() | nil
  def maybe_copy_to_latest_version(translation, text, action) do
    if copy_to_latest_version?(translation) do
      copy_to_latest_version(translation, text, action)
    end
  end

  defp copy_to_latest_version?(translation) do
    if translation.version_id && translation.source_translation_id do
      version = Repo.get(Version, translation.version_id)
      version && version.copy_on_update_translation
    else
      false
    end
  end

  defp copy_to_latest_version(translation, text, action) do
    source_translation = Repo.one!(Ecto.assoc(translation, :source_translation))
    value_type = ValueType.from_translation_new_value(source_translation, text)
    OperationMapper.map(action, source_translation, %{text: text, value_type: value_type})
  end
end
