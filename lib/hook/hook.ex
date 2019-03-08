defmodule Accent.Hook do
  def fanout(context) do
    broadcaster().fanout(context)
  end

  defp broadcaster, do: Application.get_env(:accent, :hook_broadcaster)
end
