defmodule AccentTest.Movement.Builders.TranslationUncorrectConflict do
  use Accent.RepoCase

  alias Movement.Builders.TranslationUncorrectConflict, as: TranslationUncorrectConflictBuilder

  test "builder" do
    translation = %Accent.Translation{
      key: "a",
      proposed_text: "A"
    }

    context =
      %Movement.Context{}
      |> Movement.Context.assign(:translation, translation)
      |> TranslationUncorrectConflictBuilder.build()

    operations = context.operations |> Enum.map(&Map.take(&1, [:key, :action]))

    assert operations === [
             %{
               key: "a",
               action: "uncorrect_conflict"
             }
           ]
  end
end
