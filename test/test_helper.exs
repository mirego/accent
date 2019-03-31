defmodule Accent.FormatterTestHelper do
  def test_parse(variant, parser) do
    context =
      %Langue.Formatter.SerializerResult{
        render: variant.render,
        document: %Langue.Document{
          path: "project-a",
          master_language: "en",
          top_of_the_file_comment: variant.top_of_the_file_comment,
          header: variant.header
        }
      }
      |> parser.parse()

    {variant.entries, context.entries}
  end

  def test_serialize(variant, serializer, language \\ %Langue.Language{slug: "fr"}) do
    context =
      %Langue.Formatter.ParserResult{
        entries: variant.entries,
        language: language,
        document: %Langue.Document{
          path: "project-a",
          master_language: "en",
          top_of_the_file_comment: variant.top_of_the_file_comment,
          header: variant.header
        }
      }
      |> serializer.serialize()

    {variant.render, context.render}
  end
end

defmodule Langue.Expectation.Case do
  defmacro __using__(_) do
    quote do
      def top_of_the_file_comment, do: ""
      def header, do: ""

      @callback header() :: binary()
      @callback top_of_the_file_comment() :: binary()
      @callback render() :: binary()
      @callback entries() :: [Language.Entry.t()]

      defoverridable top_of_the_file_comment: 0, header: 0
    end
  end
end

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Accent.Repo, :manual)
