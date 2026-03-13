defmodule Accent.Hook do
  @moduledoc false
  import Ecto.Query

  alias Accent.Integration
  alias Accent.Repo

  @outbounds_modules Application.compile_env!(:accent, __MODULE__)[:outbounds]

  def outbound(context, modules \\ @outbounds_modules) do
    case build_jobs(context, modules) do
      [] -> []
      jobs -> Oban.insert_all(jobs)
    end
  end

  defp build_jobs(context, modules) do
    configured_services = integration_services_for_project(context.project_id)

    Enum.flat_map(modules, fn module ->
      events = module.registered_events()
      service = if function_exported?(module, :service, 0), do: module.service()

      cond do
        events !== :all and context.event not in events -> []
        service && service not in configured_services -> []
        true -> [module.new(context)]
      end
    end)
  end

  def integration_services_for_project(project_id) do
    Integration
    |> where(project_id: ^project_id)
    |> select([i], i.service)
    |> distinct(true)
    |> Repo.all()
  end
end
