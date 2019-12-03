defmodule Accent.ProjectUpdater do
  alias Accent.Repo

  import Canada, only: [can?: 2]

  @optional_fields ~w(name main_color logo)a

  def update(project: project, params: params, user: user) do
    project
    |> cast_changeset(params, user)
    |> Repo.update()
  end

  def cast_changeset(schema, params, user) do
    fields =
      if can?(user, locked_file_operations(schema)) do
        [:locked_file_operations | @optional_fields]
      else
        @optional_fields
      end

    Ecto.Changeset.cast(schema, params, fields)
  end
end
