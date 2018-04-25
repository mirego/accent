defmodule Accent.Operation do
  use Accent.Schema

  @duplicated_fields [
    :action,
    :key,
    :text,
    :conflicted,
    :value_type,
    :file_index,
    :file_comment,
    :removed,
    :revision_id,
    :translation_id,
    :user_id,
    :batch_operation_id,
    :document_id,
    :version_id,
    :project_id,
    :stats,
    :previous_translation
  ]

  schema "operations" do
    field(:action, :string)
    field(:key, :string)
    field(:text, :string)
    field(:batch, :boolean, default: false)

    field(:file_comment, :string)
    field(:file_index, :integer)

    field(:value_type, :string)
    field(:plural, :boolean, default: false)
    field(:locked, :boolean, default: false)

    field(:rollbacked, :boolean, default: false)
    field(:stats, {:array, :map}, default: [])

    embeds_one(:previous_translation, Accent.PreviousTranslation)

    belongs_to(:document, Accent.Document)
    belongs_to(:revision, Accent.Revision)
    belongs_to(:version, Accent.Version)
    belongs_to(:translation, Accent.Translation)
    belongs_to(:project, Accent.Project)
    belongs_to(:comment, Accent.Comment)
    belongs_to(:user, Accent.User)
    belongs_to(:batch_operation, Accent.Operation)
    belongs_to(:rollbacked_operation, Accent.Operation)

    has_one(:rollback_operation, Accent.Operation, foreign_key: :rollbacked_operation_id)
    has_many(:operations, Accent.Operation, foreign_key: :batch_operation_id)

    timestamps()
  end

  @optional_fields [
    :rollbacked,
    :translation_id,
    :comment_id
  ]
  def changeset(model, params) do
    model
    |> cast(params, [] ++ @optional_fields)
  end

  def stats_changeset(model, params) do
    model
    |> cast(params, [:stats])
  end

  def copy(operation, new_fields) do
    duplicated_operation = Map.take(operation, @duplicated_fields)

    %__MODULE__{}
    |> Map.merge(duplicated_operation)
    |> Map.merge(new_fields)
  end
end
