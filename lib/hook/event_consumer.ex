defmodule Accent.Hook.EventConsumer do
  defmacro __using__(opts) do
    quote do
      use GenStage

      def start_link, do: GenStage.start_link(__MODULE__, :ok)
      def start_link(state), do: GenStage.start_link(__MODULE__, state)

      def init(state) do
        {:consumer, state, unquote(opts)}
      end
    end
  end
end
