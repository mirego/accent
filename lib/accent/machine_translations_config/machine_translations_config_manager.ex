defmodule Accent.MachineTranslationsConfigManager do
  alias Accent.Repo
  alias Ecto.Multi

  import Ecto.Changeset

  def save(project, params) do
    params = %{
      "machine_translations_config" => %{
        "config" => %{
          "key" => params[:config_key]
        },
        "enabled_actions" => params[:enabled_actions],
        "provider" => params[:provider],
        "use_platform" => params[:use_platform]
      }
    }

    changeset = cast(project, params, [:machine_translations_config])

    Multi.new()
    |> Multi.update(:project, changeset)
    |> Repo.transaction()
  end

  def delete(project) do
    changeset = put_change(cast(project, %{}, []), :machine_translations_config, nil)

    Multi.new()
    |> Multi.update(:project, changeset)
    |> Repo.transaction()
  end
end
