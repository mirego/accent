defmodule AccentTest.Movement.Builders.TranslationCorrectConflict do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Movement.Builders.TranslationCorrectConflict, as: TranslationCorrectConflictBuilder

  test "builder" do
    translation = %Accent.Translation{
      key: "a",
      proposed_text: "A"
    }

    context =
      %Movement.Context{}
      |> Movement.Context.assign(:text, "My new value")
      |> Movement.Context.assign(:translation, translation)
      |> TranslationCorrectConflictBuilder.build()

    operations = Enum.map(context.operations, &Map.take(&1, [:key, :action, :text]))

    assert operations === [
             %{
               key: "a",
               text: "My new value",
               action: "correct_conflict"
             }
           ]
  end
end
