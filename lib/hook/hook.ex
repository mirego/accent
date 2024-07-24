defmodule Accent.Hook do
  @moduledoc false
  @outbounds_modules Application.compile_env!(:accent, __MODULE__)[:outbounds]

  def outbound(context) do
    jobs =
      Enum.flat_map(@outbounds_modules, fn module ->
        events = module.registered_events()

        if events === :all or context.event in events,
          do: [module.new(context)],
          else: []
      end)

    Oban.insert_all(jobs)
  end
end
