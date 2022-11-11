defmodule Accent.Operation do
  use Accent.Schema

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
    field(:placeholders, {:array, :string}, default: [])

    field(:rollbacked, :boolean, default: false)
    field(:stats, {:array, :map}, default: [])
    field(:options, {:array, :string}, default: [])

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
    has_many(:batched_operations, Accent.Operation, foreign_key: :batch_operation_id, where: [batch: true])

    timestamps()
  end
end
