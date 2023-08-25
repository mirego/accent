defmodule Accent.GraphQL.Plugins.Authorization do
  @moduledoc false
  defmacro authorize(action, target, info, do: do_clause) do
    quote do
      with current_user when not is_nil(current_user) <- unquote(info).context[:conn].assigns[:current_user],
           true <- Canada.Can.can?(current_user, unquote(action), unquote(target)) do
        unquote(do_clause)
      else
        _ -> {:ok, nil}
      end
    end
  end
end
