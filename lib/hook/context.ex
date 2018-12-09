defmodule Accent.Hook.Context do
  alias Accent.{Project, User}

  defstruct project: %Project{}, event: "", user: %User{}, payload: %{}

  @type t :: %__MODULE__{}
end
