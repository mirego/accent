defmodule Accent.Operation do
  @moduledoc false
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
    field(:machine_translated, :boolean, default: false)

    embeds_one(:previous_translation, Accent.PreviousTranslation)

    belongs_to(:document, Accent.Document)
    belongs_to(:revision, Accent.Revision)
    belongs_to(:version, Accent.Version)
    belongs_to(:translation, Accent.Translation)
    belongs_to(:project, Accent.Project)
    belongs_to(:user, Accent.User)
    belongs_to(:batch_operation, Accent.Operation)
    belongs_to(:rollbacked_operation, Accent.Operation)

    has_one(:rollback_operation, Accent.Operation, foreign_key: :rollbacked_operation_id)
    has_many(:operations, Accent.Operation, foreign_key: :batch_operation_id)
    has_many(:batched_operations, Accent.Operation, foreign_key: :batch_operation_id, where: [batch: true])

    timestamps()
  end

  @spec to_langue_entry(map(), boolean(), String.t()) :: Langue.Entry.t()
  def to_langue_entry(operation, is_master, language_slug) do
    %Langue.Entry{
      id: operation.key,
      key: operation.key,
      value: operation.text,
      master_value: operation.text,
      is_master: is_master,
      comment: operation.file_comment,
      index: operation.file_index,
      value_type: operation.value_type,
      locked: operation.locked,
      plural: operation.plural,
      placeholders: operation.placeholders,
      language_slug: language_slug
    }
  end
end
