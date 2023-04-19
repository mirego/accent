defmodule Accent.PromptManager do
  alias Accent.{Prompt, Repo}
  alias Ecto.Multi

  import Ecto.Changeset

  def create(project, params, user) do
    changeset =
      %Prompt{project_id: project.id, author_id: user.id}
      |> cast(params, [:name, :content, :quick_access])
      |> validate_required(:content)

    Multi.new()
    |> Multi.insert(:prompt, changeset)
    |> Repo.transaction()
  end

  def update(prompt, params) do
    changeset =
      prompt
      |> cast(params, [:name, :content, :quick_access])
      |> validate_required(:content)

    Multi.new()
    |> Multi.update(:prompt, changeset)
    |> Repo.transaction()
  end

  def delete(prompt) do
    Multi.new()
    |> Multi.delete(:prompt, prompt)
    |> Repo.transaction()
  end
end
