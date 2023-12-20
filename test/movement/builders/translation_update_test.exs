defmodule AccentTest.Movement.Builders.TranslationUpdate do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Translation
  alias Movement.Builders.TranslationUpdate, as: TranslationUpdateBuilder
  alias Movement.Context

  test "builder" do
    translation = %Translation{
      key: "a",
      proposed_text: "A",
      corrected_text: "A"
    }

    context =
      %Context{}
      |> Context.assign(:text, "Updated!")
      |> Context.assign(:translation, translation)
      |> TranslationUpdateBuilder.build()

    operations = Enum.map(context.operations, &Map.take(&1, [:key, :text, :action]))

    assert operations === [
             %{
               key: "a",
               text: "Updated!",
               action: "update"
             }
           ]
  end

  test "builder same text translated" do
    translation = %Translation{
      key: "a",
      proposed_text: "A",
      corrected_text: "A",
      translated: true
    }

    context =
      %Context{}
      |> Context.assign(:text, "A")
      |> Context.assign(:translation, translation)
      |> TranslationUpdateBuilder.build()

    assert context.operations == []
  end

  test "builder same text not translated" do
    translation = %Translation{
      key: "a",
      proposed_text: "A",
      corrected_text: "A",
      translated: false
    }

    context =
      %Context{}
      |> Context.assign(:text, "A")
      |> Context.assign(:translation, translation)
      |> TranslationUpdateBuilder.build()

    assert length(context.operations) === 1
  end

  test "builder value type null to nothing" do
    translation = %Translation{
      key: "a",
      proposed_text: "null",
      corrected_text: "null",
      value_type: "null",
      placeholders: []
    }

    context =
      %Context{}
      |> Context.assign(:text, "Hello!")
      |> Context.assign(:translation, translation)
      |> TranslationUpdateBuilder.build()

    operations = Enum.map(context.operations, &Map.take(&1, [:value_type]))

    assert operations === [%{value_type: "string"}]
  end

  test "builder value type empty to nothing" do
    translation = %Translation{
      key: "a",
      proposed_text: "",
      corrected_text: "",
      value_type: "empty",
      placeholders: []
    }

    context =
      %Context{}
      |> Context.assign(:text, "Hello!")
      |> Context.assign(:translation, translation)
      |> TranslationUpdateBuilder.build()

    operations = Enum.map(context.operations, &Map.take(&1, [:value_type]))

    assert operations === [%{value_type: "string"}]
  end

  test "builder value type nothing to empty" do
    translation = %Translation{
      key: "a",
      proposed_text: "hello!",
      corrected_text: "hello!",
      value_type: "",
      placeholders: []
    }

    context =
      %Context{}
      |> Context.assign(:text, "")
      |> Context.assign(:translation, translation)
      |> TranslationUpdateBuilder.build()

    operations = Enum.map(context.operations, &Map.take(&1, [:value_type]))

    assert operations === [%{value_type: "empty"}]
  end
end
