defmodule Langue.Formatter do
  alias Langue.Formatter.ParserResult
  alias Langue.Formatter.SerializerResult

  @callback enabled?() :: boolean()
  @callback id() :: String.t()
  @callback display_name() :: String.t()
  @callback extension() :: String.t()
  @callback placeholder_regex() :: Regex.t() | :not_supported
  @callback parse(SerializerResult.t()) :: Langue.Formatter.Parser.result()
  @callback serialize(ParserResult.t()) :: Langue.Formatter.Serializer.result()

  defmacro __using__(opts) do
    quote do
      @behaviour Langue.Formatter

      def id, do: unquote(opts[:id])
      def display_name, do: unquote(opts[:display_name])
      def extension, do: unquote(opts[:extension])
      def placeholder_regex, do: :not_supported
      def enabled?, do: true

      if Keyword.has_key?(unquote(opts), :parser) do
        defdelegate parse(map), to: unquote(opts[:parser])
      else
        def parse(_), do: nil
      end

      if Keyword.has_key?(unquote(opts), :serializer) do
        defdelegate serialize(map), to: unquote(opts[:serializer])
      else
        def serialize(_), do: nil
      end

      defoverridable placeholder_regex: 0, enabled?: 0, parse: 1, serialize: 1
    end
  end
end
