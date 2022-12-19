defmodule Accent.DocumentFormat do
  defmacro ids, do: Enum.map(Langue.modules(), & &1.id)

  def all,
    do:
      Enum.map(Langue.modules(), fn module ->
        %{
          name: module.display_name(),
          slug: module.id(),
          extension: module.extension()
        }
      end)
end
