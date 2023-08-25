defmodule Accent.UserRemote.User do
  @moduledoc false
  defstruct ~w(email provider uid fullname picture_url)a

  @type t :: %__MODULE__{
          email: String.t(),
          provider: String.t(),
          uid: String.t(),
          fullname: String.t(),
          picture_url: String.t()
        }
end
