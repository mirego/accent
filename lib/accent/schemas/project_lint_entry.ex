defmodule Accent.ProjectLintEntry do
  @moduledoc false
  use Accent.Schema

  schema "project_lint_entries" do
    field(:check_ids, {:array, :string})
    field(:value, :string)
    field(:type, Ecto.Enum, values: [:all, :term, :language_tool_rule_id, :key])
    belongs_to(:project, Accent.Project)

    timestamps()
  end

  @cast_fields ~w(check_ids value type project_id)a
  @required_fields ~w(type project_id)a

  def create_changeset(model, params) do
    model
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:project)
  end

  def update_changeset(model, params) do
    model
    |> cast(params, ~w(check_ids value type)a)
    |> validate_required(~w(type)a)
  end
end
