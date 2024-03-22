alias Ecto.Adapters.SQL.Sandbox

defmodule Accent.FormatterTestHelper do
  @moduledoc false
  def test_parse(variant, parser) do
    context =
      parser.parse(%Langue.Formatter.SerializerResult{
        render: variant.render,
        document: %Langue.Document{
          path: "project-a",
          master_language: "en",
          top_of_the_file_comment: variant.top_of_the_file_comment,
          header: variant.header
        }
      })

    {variant.entries, context.entries}
  end

  def test_serialize(variant, serializer, language \\ %Langue.Language{slug: "fr"}) do
    context =
      serializer.serialize(%Langue.Formatter.ParserResult{
        entries: variant.entries,
        language: language,
        document: %Langue.Document{
          path: "project-a",
          master_language: "en",
          top_of_the_file_comment: variant.top_of_the_file_comment,
          header: variant.header
        }
      })

    {variant.render, context.render}
  end
end

defmodule Langue.Expectation.Case do
  @moduledoc false
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

Sandbox.checkout(Accent.Repo)
Accent.Factory.bootstrap()
Sandbox.checkin(Accent.Repo)

Sandbox.mode(Accent.Repo, :manual)
