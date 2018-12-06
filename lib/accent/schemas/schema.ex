defmodule Accent.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @type t :: struct
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @timestamps_opts [type: :utc_datetime_usec]

      import Ecto
      import Ecto.Changeset
    end
  end
end
