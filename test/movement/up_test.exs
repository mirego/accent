defmodule AccentTest.Movement.Migrator.Up do
  use Accent.RepoCase

  alias Movement.Migrator

  alias Accent.{
    Operation,
    PreviousTranslation,
    Repo,
    Revision,
    Translation,
    User
  }

  test ":noop" do
    assert {:ok, :noop} == Migrator.up(%{action: "noop"})
  end

  test ":correct" do
    user = %User{} |> Repo.insert!()
    revision = %Revision{} |> Repo.insert!()

    translation =
      Repo.insert!(%Translation{
        key: "to_be_corrected",
        file_comment: "",
        corrected_text: nil,
        proposed_text: "proposed_text",
        conflicted_text: nil,
        conflicted: true,
        removed: false
      })

    Migrator.up(%Operation{
      id: Ecto.UUID.generate(),
      action: "correct_conflict",
      translation: translation,
      revision_id: revision.id,
      user_id: user.id,
      text: "new proposed text",
      previous_translation: PreviousTranslation.from_translation(translation)
    })

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.conflicted == false
    assert new_translation.proposed_text == "proposed_text"
    assert new_translation.corrected_text == "new proposed text"
    assert new_translation.conflicted_text == nil
  end

  test ":uncorrect" do
    translation =
      Repo.insert!(%Translation{
        key: "to_be_uncorrected",
        file_comment: "",
        file_index: 1,
        corrected_text: "new proposed text",
        proposed_text: "proposed_text",
        conflicted_text: "foo",
        conflicted: false,
        removed: false
      })

    Migrator.up(%Operation{
      action: "uncorrect_conflict",
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
        file_comment: "",
        file_index: 1,
        corrected_text: "proposed_text",
        proposed_text: "proposed_text",
        conflicted_text: "previous conflicted",
        conflicted: false,
        removed: false
      })

    Migrator.up(%Operation{
      action: "uncorrect_conflict",
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

  test ":remove" do
    translation =
      Repo.insert!(%Translation{
        key: "to_be_removed",
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

  test ":conflict_on_proposed" do
    translation =
      Repo.insert!(%Translation{
        value_type: "",
        key: "to_be_conflict_on_proposed",
        file_comment: "",
        file_index: 1,
        corrected_text: "corrected_text",
        proposed_text: "proposed_text",
        conflicted: true,
        removed: false,
        placeholders: []
      })

    Migrator.up(%{
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
end
