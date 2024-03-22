defmodule AccentTest.OperationBatcher do
  @moduledoc false
  use Accent.RepoCase, async: true

  import Ecto.Query

  alias Accent.Operation
  alias Accent.OperationBatcher
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.User

  setup do
    user = Factory.insert(User)
    revision = Factory.insert(Revision)
    translation_one = Factory.insert(Translation, key: "a", conflicted: true, revision_id: revision.id)
    translation_two = Factory.insert(Translation, key: "b", conflicted: true, revision_id: revision.id)

    [user: user, revision: revision, translations: [translation_one, translation_two]]
  end

  test "create batch with close operations", %{user: user, revision: revision, translations: [translation_one, _]} do
    operations =
      Enum.map(
        [
          Factory.insert(Operation,
            action: "correct_conflict",
            key: "a",
            text: "B",
            translation_id: translation_one.id,
            user_id: user.id,
            revision_id: revision.id,
            project_id: revision.project_id,
            inserted_at: DateTime.utc_now()
          )
        ],
        &Map.get(&1, :id)
      )

    operation =
      Factory.insert(Operation,
        action: "correct_conflict",
        key: "a",
        text: "C",
        translation_id: translation_one.id,
        user_id: user.id,
        revision_id: revision.id,
        project_id: revision.project_id,
        inserted_at: DateTime.utc_now()
      )

    batch_responses = OperationBatcher.batch(operation)

    updated_operations =
      Operation
      |> where([o], o.id in ^operations)
      |> or_where(id: ^operation.id)
      |> Repo.all()
      |> Enum.map(&Map.get(&1, :batch_operation_id))
      |> Enum.uniq()

    batch_operation = Repo.get_by(Operation, action: "batch_correct_conflict")

    assert batch_responses == {2, nil}
    assert updated_operations == [batch_operation.id]
    assert batch_operation.stats == [%{"count" => 2, "action" => "correct_conflict"}]
  end

  test "create batch with close operations but some not so close with existing batch operation", %{
    user: user,
    revision: revision,
    translations: [translation_one, translation_two]
  } do
    batch_operation =
      Factory.insert(Operation,
        action: "batch_correct_conflict",
        user_id: user.id,
        revision_id: revision.id,
        project_id: revision.project_id,
        stats: [%{"count" => 2, "action" => "correct_conflict"}],
        inserted_at:
          DateTime.utc_now()
          |> DateTime.to_naive()
          |> NaiveDateTime.add(-960, :second)
          |> DateTime.from_naive!("Etc/UTC")
      )

    operations =
      Enum.map(
        [
          Factory.insert(Operation,
            action: "correct_conflict",
            key: "a",
            text: "B",
            translation_id: translation_one.id,
            user_id: user.id,
            revision_id: revision.id,
            project_id: revision.project_id,
            batch_operation_id: batch_operation.id,
            inserted_at:
              DateTime.utc_now()
              |> DateTime.to_naive()
              |> NaiveDateTime.add(-960, :second)
              |> DateTime.from_naive!("Etc/UTC")
          ),
          Factory.insert(Operation,
            action: "correct_conflict",
            key: "b",
            text: "C",
            translation_id: translation_two.id,
            user_id: user.id,
            revision_id: revision.id,
            project_id: revision.project_id,
            batch_operation_id: batch_operation.id,
            inserted_at: DateTime.utc_now()
          )
        ],
        &Map.get(&1, :id)
      )

    operation =
      Factory.insert(Operation,
        action: "correct_conflict",
        key: "a",
        text: "B",
        translation_id: translation_one.id,
        user_id: user.id,
        revision_id: revision.id,
        project_id: revision.project_id,
        inserted_at: DateTime.utc_now()
      )

    batch_responses = Accent.OperationBatcher.batch(operation)

    updated_operations =
      Operation
      |> where([o], o.id in ^operations)
      |> or_where(id: ^operation.id)
      |> Repo.all()
      |> Enum.map(&Map.get(&1, :batch_operation_id))
      |> Enum.uniq()

    batch_operation = Repo.get_by(Operation, action: "batch_correct_conflict")

    assert batch_responses == {2, nil}
    assert updated_operations == [batch_operation.id]
    assert batch_operation.stats == [%{"count" => 3, "action" => "correct_conflict"}]
  end

  test "don’t create batch with operations happening in more than 60 minutes", %{
    user: user,
    revision: revision,
    translations: [translation_one, translation_two]
  } do
    operations =
      [
        %Operation{
          action: "correct_conflict",
          key: "a",
          text: "B",
          translation_id: translation_one.id,
          user_id: user.id,
          revision_id: revision.id,
          project_id: revision.project_id,
          inserted_at:
            DateTime.utc_now()
            |> DateTime.to_naive()
            |> NaiveDateTime.add(-3960, :second)
            |> DateTime.from_naive!("Etc/UTC")
        },
        %Operation{
          action: "correct_conflict",
          key: "b",
          text: "C",
          translation_id: translation_two.id,
          user_id: user.id,
          revision_id: revision.id,
          project_id: revision.project_id,
          inserted_at:
            DateTime.utc_now()
            |> DateTime.to_naive()
            |> NaiveDateTime.add(-3960, :second)
            |> DateTime.from_naive!("Etc/UTC")
        }
      ]
      |> Enum.map(&Repo.insert!/1)
      |> Enum.map(&Map.get(&1, :id))

    operation =
      Factory.insert(Operation,
        action: "correct_conflict",
        key: "a",
        text: "B",
        translation_id: translation_one.id,
        user_id: user.id,
        revision_id: revision.id,
        project_id: revision.project_id,
        inserted_at: DateTime.utc_now()
      )

    batch_responses = Accent.OperationBatcher.batch(operation)

    updated_operations =
      Operation
      |> where([o], o.id in ^operations)
      |> or_where(id: ^operation.id)
      |> Repo.all()
      |> Enum.map(&Map.get(&1, :batch_operation_id))
      |> Enum.uniq()

    assert batch_responses == {0, nil}
    assert updated_operations == [nil]
  end
end
