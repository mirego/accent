defmodule Movement.Migrator.Macros do
  defmacro up(action, value) when is_tuple(value) do
    quote do
      def up(operation = %{action: unquote(to_string(action))}), do: unquote(value)
    end
  end

  defmacro up(action, module, function) do
    module = Macro.expand(module, __CALLER__)

    quote do
      def up(operation = %{action: unquote(to_string(action))}) do
        {:ok, result} = unquote(module).call(unquote(function), operation)

        result
      end
    end
  end

  defmacro down(action, value) when is_tuple(value) do
    quote do
      def down(operation = %{action: unquote(to_string(action))}), do: unquote(value)
    end
  end

  defmacro down(action, module, function) do
    module = Macro.expand(module, __CALLER__)

    quote do
      def down(operation = %{action: unquote(to_string(action))}) do
        {:ok, result} = unquote(module).call(unquote(function), operation)

        result
      end
    end
  end
end
