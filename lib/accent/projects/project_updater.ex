defmodule Accent.ProjectUpdater do
  alias Accent.Repo

  import Canada, only: [can?: 2]

  @optional_fields ~w(name main_color)a

  def update(project: project, params: params, user: user) do
    project
    |> cast_changeset(params, user)
    |> Repo.update()
  end

  def cast_changeset(model, params, user) do
    fields =
      if user |> can?(locked_file_operations(model)) do
        [:locked_file_operations | @optional_fields]
      else
        @optional_fields
      end

    model
    |> Ecto.Changeset.cast(params, fields)
  end
end
