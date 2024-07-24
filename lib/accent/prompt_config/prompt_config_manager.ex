defmodule Accent.PromptConfigManager do
  @moduledoc false
  import Ecto.Changeset

  alias Accent.Repo
  alias Ecto.Multi

  def save(project, params) do
    params = %{
      "prompt_config" => %{
        "config" => %{
          "key" => params[:config_key]
        },
        "provider" => params[:provider],
        "use_platform" => params[:use_platform]
      }
    }

    changeset = cast(project, params, [:prompt_config])

    Multi.new()
    |> Multi.update(:project, changeset)
    |> Repo.transaction()
  end

  def delete(project) do
    changeset = put_change(cast(project, %{}, []), :prompt_config, nil)

    Multi.new()
    |> Multi.update(:project, changeset)
    |> Repo.transaction()
  end
end
