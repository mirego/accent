defmodule AccentTest.Migrator.Down do
  use Accent.RepoCase

  alias Accent.{
    Operation,
    PreviousTranslation,
    Repo,
    Translation
  }

  alias Movement.Migrator

  test ":noop" do
    assert nil == Migrator.down(%{action: "noop"})
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
      Repo.insert!(%Translation{
        key: "to_be_in_conflict",
        corrected_text: nil,
        proposed_text: "new proposed text",
        conflicted_text: "corrected_text",
        conflicted: true
      })

    Migrator.down(
      %Operation{
        action: "conflict_on_corrected",
        translation: translation,
        previous_translation: PreviousTranslation.from_translation(previous_translation)
      }
      |> Repo.insert!()
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
      Repo.insert!(%Translation{
        key: "to_be_in_proposed",
        corrected_text: nil,
        proposed_text: "new proposed text",
        conflicted_text: "proposed_text",
        conflicted: true
      })

    Migrator.down(
      %Operation{
        action: "conflict_on_proposed",
        translation: translation,
        previous_translation: PreviousTranslation.from_translation(previous_translation)
      }
      |> Repo.insert!()
    )

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.conflicted == true
    assert new_translation.proposed_text == "proposed_text"
    assert new_translation.corrected_text == nil
    assert new_translation.conflicted_text == nil
  end

  test ":new" do
    translation =
      Repo.insert!(%Translation{
        key: "to_be_added_down",
        corrected_text: nil,
        proposed_text: "new text",
        conflicted_text: nil,
        conflicted: true
      })

    Migrator.down(
      %Operation{
        action: "new",
        translation: translation
      }
      |> Repo.insert!()
    )

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.removed == true
  end

  test ":renew" do
    translation =
      Repo.insert!(%Translation{
        key: "to_be_added_down",
        corrected_text: nil,
        proposed_text: "new text",
        conflicted_text: nil,
        conflicted: true
      })

    Migrator.down(
      %Operation{
        action: "renew",
        translation: translation
      }
      |> Repo.insert!()
    )

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.removed == true
  end

  test ":remove" do
    translation =
      Repo.insert!(%Translation{
        value_type: "",
        key: "to_be_added_down",
        corrected_text: nil,
        proposed_text: "new text",
        conflicted_text: nil,
        conflicted: true,
        placeholders: []
      })

    Migrator.down(
      %Operation{
        action: "remove",
        translation: translation
      }
      |> Repo.insert!()
    )

    new_translation = Repo.get!(Translation, translation.id)

    assert new_translation.removed == false
  end
end
