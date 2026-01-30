defmodule AccentTest.Migrator.Down do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Operation
  alias Accent.PreviousTranslation
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Movement.Migrator

  test ":noop" do
    assert [] === Migrator.down(%{action: "noop"})
  end

  test ":conflict_on_corrected" do
    previous_translation = %{
      value_type: "",
      corrected_text: "corrected_text",
      proposed_text: "proposed_text",
      conflicted_text: nil,
      conflicted: false,
      removed: false,
      placeholders: []
    }

    translation =
      Factory.insert(Translation,
        key: "to_be_in_conflict",
        revision: Factory.insert(Revision),
        corrected_text: nil,
        proposed_text: "new proposed text",
        conflicted_text: "corrected_text",
        conflicted: true
      )

    Migrator.down(
      Factory.insert(Operation,
        action: "conflict_on_corrected",
        translation: translation,
        previous_translation: PreviousTranslation.from_translation(previous_translation)
      )
    )

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.conflicted == false
    assert new_translation.proposed_text == "proposed_text"
    assert new_translation.corrected_text == "corrected_text"
    assert new_translation.conflicted_text == nil
  end

  test ":conflict_on_proposed" do
    previous_translation = %{
      value_type: "",
      corrected_text: nil,
      proposed_text: "proposed_text",
      conflicted_text: nil,
      conflicted: true,
      removed: false,
      placeholders: []
    }

    translation =
      Factory.insert(Translation,
        key: "to_be_in_proposed",
        revision: Factory.insert(Revision),
        corrected_text: nil,
        proposed_text: "new proposed text",
        conflicted_text: "proposed_text",
        conflicted: true
      )

    Migrator.down(
      Factory.insert(Operation,
        action: "conflict_on_proposed",
        translation: translation,
        previous_translation: PreviousTranslation.from_translation(previous_translation)
      )
    )

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.conflicted == true
    assert new_translation.proposed_text == "proposed_text"
    assert new_translation.corrected_text == nil
    assert new_translation.conflicted_text == nil
  end

  test ":new" do
    translation =
      Factory.insert(Translation,
        key: "to_be_added_down",
        revision: Factory.insert(Revision),
        corrected_text: nil,
        proposed_text: "new text",
        conflicted_text: nil,
        conflicted: true
      )

    Migrator.down(Factory.insert(Operation, action: "new", translation: translation))

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.removed == true
  end

  test ":new clears source_translation_id on versioned translations" do
    revision = Factory.insert(Revision)

    source_translation =
      Factory.insert(Translation,
        key: "hello",
        revision: revision,
        corrected_text: "Hello",
        proposed_text: "Hello",
        version_id: nil
      )

    versioned_translation =
      Factory.insert(Translation,
        key: "hello",
        revision: revision,
        corrected_text: "Hello",
        proposed_text: "Hello",
        source_translation_id: source_translation.id
      )

    Migrator.down(Factory.insert(Operation, action: "new", translation: source_translation))

    updated_source = Repo.get!(Translation, source_translation.id)
    updated_versioned = Repo.get!(Translation, versioned_translation.id)

    assert updated_source.removed == true
    assert updated_versioned.source_translation_id == nil
  end

  test ":renew" do
    translation =
      Factory.insert(Translation,
        key: "to_be_added_down",
        revision: Factory.insert(Revision),
        corrected_text: nil,
        proposed_text: "new text",
        conflicted_text: nil,
        conflicted: true
      )

    Migrator.down(Factory.insert(Operation, action: "renew", translation: translation))

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.removed == true
  end

  test ":remove" do
    translation =
      Factory.insert(Translation,
        value_type: "",
        revision: Factory.insert(Revision),
        key: "to_be_added_down",
        corrected_text: nil,
        proposed_text: "new text",
        conflicted_text: nil,
        conflicted: true,
        placeholders: []
      )

    Migrator.down(Factory.insert(Operation, action: "remove", translation: translation))

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.removed == false
  end
end
