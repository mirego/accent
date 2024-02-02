defmodule Accent.Hook do
  @moduledoc false
  def outbound(context), do: run(outbounds_modules(), context)

  defp run(modules, context) do
    jobs =
      Enum.reduce(modules, [], fn {module, opts}, acc ->
        if context.event in Keyword.fetch!(opts, :events),
          do: [module.new(context) | acc],
          else: acc
      end)

    Oban.insert_all(jobs)
  end

  defp outbounds_modules do
    Application.get_env(:accent, __MODULE__)[:outbounds]
  end
end
