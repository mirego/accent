defmodule Accent.ProjectLintEntry do
  @moduledoc false
  use Accent.Schema

  schema "project_lint_entries" do
    field(:check_ids, {:array, :string})
    field(:value, :string)
    field(:type, Ecto.Enum, values: [:all, :term, :language_tool_rule_id, :key])
    field(:ignore, :boolean)
    belongs_to(:project, Accent.Project)

    timestamps()
  end
end
