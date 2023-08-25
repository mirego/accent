defmodule Accent.DocumentManager do
  @moduledoc false
  import Ecto.Changeset

  alias Accent.Repo

  def update(document, params) do
    document
    |> cast(params, [:path])
    |> validate_required(:path)
    |> unique_constraint(:path, name: :documents_path_format_project_id_index)
    |> Repo.update()
  end
end
