defmodule Accent.Translation do
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
    field(:message_context, :string, default: "")

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
    message_context
  )a
  def changeset(model, params) do
    model
    |> cast(params, @optional_fields)
  end
end
