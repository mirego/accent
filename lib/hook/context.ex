defmodule Accent.Hook.Context do
  alias Accent.{User, Project}

  defstruct project: %Project{}, event: "", user: %User{}, payload: %{}

  @type t :: %__MODULE__{}
end
