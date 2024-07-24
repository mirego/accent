defmodule Accent.Hook.Outbounds.Helpers.StringTemplate do
  @moduledoc false

  defmacro deftemplate(name, template) do
    quote do
      require EEx

      EEx.function_from_string(:def, unquote(name), unquote(template), [:assigns], trim: true)
    end
  end
end
