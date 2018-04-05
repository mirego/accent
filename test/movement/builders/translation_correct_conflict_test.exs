defmodule AccentTest.Movement.Builders.TranslationCorrectConflict do
  use Accent.RepoCase

  alias Movement.Builders.TranslationCorrectConflict, as: TranslationCorrectConflictBuilder

  alias Accent.{
    Translation
  }

  test "builder" do
    translation = %Translation{
      key: "a",
      proposed_text: "A"
    }

    context =
      %Movement.Context{}
      |> Movement.Context.assign(:text, "My new value")
      |> Movement.Context.assign(:translation, translation)
      |> TranslationCorrectConflictBuilder.build()

    operations = context.operations |> Enum.map(&Map.take(&1, [:key, :action, :text]))

    assert operations === [
             %{
               key: "a",
               text: "My new value",
               action: "correct_conflict"
             }
           ]
  end
end
