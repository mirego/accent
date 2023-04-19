defmodule Accent.Prompt do
  use Accent.Schema

  schema "prompts" do
    field(:name, :string)
    field(:content, :string)
    field(:quick_access, :string)

    belongs_to(:project, Accent.Project)
    belongs_to(:author, Accent.User)

    timestamps()
  end
end
