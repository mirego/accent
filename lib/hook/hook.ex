defmodule Accent.Hook do
  @moduledoc false
  def outbound(context), do: run(outbounds_modules(), context)
  def inbound(context), do: run(inbounds_modules(), context)

  defp run(modules, context) do
    modules
    |> Enum.reduce([], fn {module, opts}, acc ->
      if context.event in Keyword.fetch!(opts, :events),
        do: [module.new(context) | acc],
        else: acc
    end)
    |> Oban.insert_all()
  end

  defp outbounds_modules do
    Application.get_env(:accent, __MODULE__)[:outbounds]
  end

  defp inbounds_modules do
    Application.get_env(:accent, __MODULE__)[:inbounds]
  end
end
