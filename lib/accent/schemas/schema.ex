defmodule Accent.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @type t :: struct
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id

      import Ecto
      import Ecto.Changeset
    end
  end
end
