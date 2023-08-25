defmodule Accent.Hook.Context do
  @moduledoc false
  alias Accent.Project
  alias Accent.Repo
  alias Accent.User

  @derive {Jason.Encoder, except: ~w(project user)a}
  @enforce_keys ~w(project_id user_id event payload)a
  defstruct project: nil, project_id: nil, event: "", user: nil, user_id: nil, payload: %{}

  @type t :: %__MODULE__{}

  def from_worker(context) do
    %__MODULE__{
      project_id: context["project_id"],
      project: Repo.get(Project, context["project_id"]),
      user_id: context["user_id"],
      user: Repo.get(User, context["user_id"]),
      event: context["event"],
      payload: context["payload"]
    }
  end
end
