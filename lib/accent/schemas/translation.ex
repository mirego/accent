defmodule Accent.Translation do
  @moduledoc false
  use Accent.Schema

  schema "translations" do
    field(:key, :string)
    field(:proposed_text, :string, default: "")
    field(:corrected_text, :string, default: "")
    field(:conflicted_text, :string, default: "")
    field(:conflicted, :boolean, default: false)
    field(:removed, :boolean, default: false)
    field(:comments_count, :integer, default: 0)

    field(:file_comment, :string)
    field(:file_index, :integer)

    field(:value_type, :string, default: "string")
    field(:plural, :boolean, default: false)
    field(:locked, :boolean, default: false)
    field(:placeholders, {:array, :string}, default: [])

    belongs_to(:document, Accent.Document)
    belongs_to(:revision, Accent.Revision)
    has_one(:project, through: [:revision, :project])
    belongs_to(:version, Accent.Version)
    belongs_to(:source_translation, __MODULE__)
    has_many(:operations, Accent.Operation)
    has_many(:comments, Accent.Comment)
    has_many(:comments_subscriptions, Accent.TranslationCommentsSubscription)

    field(:marked_as_removed, :string, virtual: true)
    field(:text, :string, virtual: true)
    field(:master_translation, :any, virtual: true, default: %Ecto.Association.NotLoaded{})

    timestamps()
  end

  @optional_fields ~w(
    proposed_text
    corrected_text
    conflicted_text
    conflicted
    removed
    comments_count
    file_index
    file_comment
    value_type
    document_id
    placeholders
  )a
  def changeset(struct, params) do
    cast(struct, params, @optional_fields)
  end

  @spec to_langue_entry(map(), map(), boolean, String.t()) :: Langue.Entry.t()
  def to_langue_entry(translation, master_translation, is_master, language_slug) do
    %Langue.Entry{
      id: translation.id,
      key: translation.key,
      value: translation.corrected_text,
      master_value: master_translation && master_translation.corrected_text,
      is_master: is_master,
      comment: translation.file_comment,
      index: translation.file_index,
      value_type: translation.value_type,
      locked: translation.locked,
      plural: translation.plural,
      placeholders: translation.placeholders,
      placeholder_regex: extract_translation_document_placeholder_regex(translation),
      language_slug: language_slug
    }
  end

  defp extract_translation_document_placeholder_regex(translation) do
    with true <- is_struct(translation.document, Accent.Document),
         {:ok, regex} <- Langue.placeholder_regex_from_format(translation.document.format) do
      regex
    else
      _ -> nil
    end
  end

  def maybe_natural_order_by(translations, "key") do
    Enum.sort_by(translations, & &1.key)
  end

  def maybe_natural_order_by(translations, "-key") do
    Enum.sort_by(translations, & &1.key, &>=/2)
  end

  def maybe_natural_order_by(translations, _), do: translations
end
