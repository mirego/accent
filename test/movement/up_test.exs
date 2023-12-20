defmodule AccentTest.Movement.Migrator.Up do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Operation
  alias Accent.PreviousTranslation
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.User
  alias Movement.Migrator

  test ":noop" do
    assert [] === Migrator.up(%{action: "noop"})
  end

  test ":correct" do
    user = Repo.insert!(%User{})
    revision = Repo.insert!(%Revision{})

    translation =
      Repo.insert!(%Translation{
        key: "to_be_corrected",
        revision: Repo.insert!(%Revision{}),
        file_comment: "",
        corrected_text: nil,
        proposed_text: "proposed_text",
        conflicted_text: nil,
        conflicted: true,
        value_type: "string",
        removed: false
      })

    Migrator.up(%Operation{
      id: Ecto.UUID.generate(),
      action: "correct_conflict",
      translation: translation,
      revision_id: revision.id,
      user_id: user.id,
      text: "new proposed text",
      value_type: "string",
      previous_translation: PreviousTranslation.from_translation(translation)
    })

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.conflicted == false
    assert new_translation.proposed_text == "proposed_text"
    assert new_translation.corrected_text == "new proposed text"
    assert new_translation.conflicted_text == nil
  end

  test ":merge_on_proposed_force" do
    user = Repo.insert!(%User{})
    revision = Repo.insert!(%Revision{})

    translation =
      Repo.insert!(%Translation{
        key: "to_be_merged",
        revision: Repo.insert!(%Revision{}),
        file_comment: "",
        corrected_text: "corrected_text",
        proposed_text: "proposed_text",
        value_type: "string",
        conflicted_text: nil,
        conflicted: true,
        removed: false
      })

    Migrator.up(%Operation{
      id: Ecto.UUID.generate(),
      action: "merge_on_proposed_force",
      translation: translation,
      revision_id: revision.id,
      user_id: user.id,
      text: "new text",
      value_type: "string",
      previous_translation: PreviousTranslation.from_translation(translation)
    })

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.proposed_text == "new text"
    assert new_translation.corrected_text == "new text"
    assert new_translation.conflicted_text == "corrected_text"
  end

  test ":merge_on_corrected" do
    user = Repo.insert!(%User{})
    revision = Repo.insert!(%Revision{})

    translation =
      Repo.insert!(%Translation{
        key: "to_be_merged",
        revision: Repo.insert!(%Revision{}),
        corrected_text: "corrected_text",
        proposed_text: "proposed_text",
        conflicted_text: nil,
        value_type: "string",
        conflicted: true
      })

    Migrator.up(%Operation{
      action: "merge_on_corrected",
      translation: translation,
      revision_id: revision.id,
      value_type: "string",
      user_id: user.id,
      text: "new text"
    })

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.proposed_text == "new text"
    assert new_translation.corrected_text == "new text"
    assert new_translation.conflicted_text == nil
  end

  test ":uncorrect" do
    translation =
      Repo.insert!(%Translation{
        key: "to_be_uncorrected",
        revision: Repo.insert!(%Revision{}),
        file_comment: "",
        file_index: 1,
        corrected_text: "new proposed text",
        proposed_text: "proposed_text",
        conflicted_text: "foo",
        conflicted: false,
        removed: false,
        value_type: "string"
      })

    Migrator.up(%Operation{
      action: "uncorrect_conflict",
      value_type: "string",
      text: "new proposed text",
      translation: translation,
      previous_translation: PreviousTranslation.from_translation(translation)
    })

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.conflicted == true
    assert new_translation.proposed_text == "proposed_text"
    assert new_translation.corrected_text == "new proposed text"
    assert new_translation.conflicted_text == "foo"
  end

  test ":uncorrect with same corrected and proposed" do
    translation =
      Repo.insert!(%Translation{
        key: "to_be_uncorrected",
        revision: Repo.insert!(%Revision{}),
        file_comment: "",
        file_index: 1,
        corrected_text: "proposed_text",
        proposed_text: "proposed_text",
        conflicted_text: "previous conflicted",
        value_type: "string",
        conflicted: false,
        translated: true,
        removed: false
      })

    Migrator.up(%Operation{
      action: "uncorrect_conflict",
      value_type: "string",
      text: "proposed_text",
      translation: translation,
      previous_translation: PreviousTranslation.from_translation(translation)
    })

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.conflicted == true
    assert new_translation.proposed_text == "proposed_text"
    assert new_translation.corrected_text == "proposed_text"
    assert new_translation.conflicted_text == "previous conflicted"
  end

  test ":conflict_on_corrected" do
    translation =
      Repo.insert!(%Translation{
        key: "to_be_in_conflict",
        revision: Repo.insert!(%Revision{}),
        file_comment: "",
        file_index: 1,
        corrected_text: "corrected_text",
        proposed_text: "proposed_text",
        conflicted: false,
        removed: false
      })

    Migrator.up(%Operation{
      action: "conflict_on_corrected",
      translation: translation,
      text: "new proposed text",
      value_type: "string",
      previous_translation: PreviousTranslation.from_translation(translation),
      placeholders: []
    })

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.conflicted == true
    assert new_translation.proposed_text == "new proposed text"
    assert new_translation.conflicted_text == translation.corrected_text
  end

  test ":conflict_on_slave" do
    translation =
      Repo.insert!(%Translation{
        key: "to_be_in_conflict",
        revision: Repo.insert!(%Revision{}),
        file_comment: "",
        file_index: 1,
        corrected_text: "corrected_text",
        proposed_text: "proposed_text",
        conflicted: false,
        removed: false
      })

    Migrator.up(%Operation{
      action: "conflict_on_slave",
      translation: translation,
      text: "new proposed text on master",
      value_type: "string",
      previous_translation: PreviousTranslation.from_translation(translation),
      placeholders: []
    })

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.conflicted == true
    assert new_translation.proposed_text == "proposed_text"
  end

  test ":remove" do
    translation =
      Repo.insert!(%Translation{
        key: "to_be_removed",
        revision: Repo.insert!(%Revision{}),
        corrected_text: "corrected_text",
        proposed_text: "proposed_text",
        conflicted: false,
        removed: false
      })

    Migrator.up(%Operation{
      action: "remove",
      translation: translation,
      previous_translation: PreviousTranslation.from_translation(translation)
    })

    new_translation = Repo.get(Translation, translation.id)

    assert new_translation.removed == true
  end

  test ":renew" do
    translation =
      Repo.insert!(%Translation{
        key: "to_be_renewed",
        revision: Repo.insert!(%Revision{}),
        corrected_text: "corrected_text",
        proposed_text: "proposed_text",
        conflicted: false,
        removed: true
      })

    operation =
      Repo.insert!(%Operation{
        action: "renew",
        translation: translation,
        previous_translation: PreviousTranslation.from_translation(translation)
      })

    Migrator.up(operation)

    updated_translation = Repo.get(Translation, translation.id)

    assert updated_translation.removed == false
  end

  test ":rollback" do
    translation =
      Repo.insert!(%Translation{
        key: "to_be_rollbacked",
        revision: Repo.insert!(%Revision{}),
        corrected_text: "corrected_text",
        proposed_text: "proposed_text",
        conflicted: false,
        removed: true
      })

    operation =
      Repo.insert!(%Operation{
        action: "rollback",
        translation: translation,
        previous_translation: PreviousTranslation.from_translation(%{translation | corrected_text: "previous"})
      })

    Migrator.up(operation)

    updated_translation = Repo.get(Translation, translation.id)

    assert updated_translation.corrected_text == "previous"
  end

  test ":conflict_on_proposed" do
    translation =
      Repo.insert!(%Translation{
        value_type: "",
        key: "to_be_conflict_on_proposed",
        revision: Repo.insert!(%Revision{}),
        file_comment: "",
        file_index: 1,
        corrected_text: "corrected_text",
        proposed_text: "proposed_text",
        conflicted: true,
        removed: false,
        placeholders: []
      })

    Migrator.up(%Operation{
      value_type: "",
      action: "conflict_on_proposed",
      file_comment: "New comment",
      file_index: 1,
      text: "conflict",
      translation: translation,
      previous_translation: PreviousTranslation.from_translation(translation),
      placeholders: []
    })

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.conflicted == true
    assert new_translation.proposed_text == "conflict"
    assert new_translation.corrected_text == "conflict"
    assert new_translation.conflicted_text == "corrected_text"
    assert new_translation.file_comment == "New comment"
  end

  test ":updated_proposed" do
    translation =
      Repo.insert!(%Translation{
        key: "updated_proposed",
        revision: Repo.insert!(%Revision{}),
        corrected_text: "corrected_text",
        proposed_text: "proposed_text",
        conflicted_text: "conflict",
        conflicted: true,
        removed: false
      })

    Migrator.up(%Operation{
      action: "update_proposed",
      text: "update",
      translation: translation,
      previous_translation: PreviousTranslation.from_translation(translation)
    })

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.conflicted == true
    assert new_translation.proposed_text == "update"
    assert new_translation.corrected_text == "corrected_text"
    assert new_translation.conflicted_text == "conflict"
  end
end
