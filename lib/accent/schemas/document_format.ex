defmodule Accent.DocumentFormat do
  @moduledoc false
  defmacro ids, do: Enum.map(Langue.modules(), & &1.id)

  def all do
    Enum.map(Langue.modules(), fn module ->
      %{name: module.display_name(), slug: module.id(), extension: module.extension()}
    end)
  end

  def extension_by_format(slug) do
    Enum.find_value(Langue.modules(), fn module ->
      module.id() === slug && module.extension()
    end)
  end
end
