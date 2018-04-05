defmodule Accessible do
  @moduledoc false

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Access

      def fetch(struct, key), do: Map.fetch(struct, key)

      def get(struct, key, default \\ nil) do
        case struct do
          %{^key => value} -> value
          _else -> default
        end
      end

      def put(struct, key, val) do
        if Map.has_key?(struct, key) do
          Map.put(struct, key, val)
        else
          struct
        end
      end

      def delete(struct, key) do
        put(struct, key, struct(__MODULE__)[key])
      end

      def get_and_update(struct, key, fun) when is_function(fun, 1) do
        current = get(struct, key)

        case fun.(current) do
          {value, update} ->
            {value, put(struct, key, update)}

          :pop ->
            {current, delete(struct, key)}

          other ->
            raise "the given function must return a two-element tuple or :pop, got: #{inspect(other)}"
        end
      end

      def pop(struct, key, default \\ nil) do
        val = get(struct, key, default)
        updated = delete(struct, key)
        {val, updated}
      end

      defoverridable fetch: 2, get: 3, put: 3, delete: 2, get_and_update: 3, pop: 3
    end
  end
end
