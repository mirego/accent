defmodule AccentTest.Movement.Builders.TranslationUncorrectConflict do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Movement.Builders.TranslationUncorrectConflict, as: TranslationUncorrectConflictBuilder

  test "builder" do
    translation = %Accent.Translation{
      key: "a",
      proposed_text: "A"
    }

    context =
      %Movement.Context{}
      |> Movement.Context.assign(:translation, translation)
      |> Movement.Context.assign(:text, "B")
      |> TranslationUncorrectConflictBuilder.build()

    operations = Enum.map(context.operations, &Map.take(&1, [:key, :action, :text]))

    assert operations === [
             %{
               key: "a",
               text: "B",
               action: "uncorrect_conflict"
             }
           ]
  end
end
