defmodule Accent.Hook do
  def notify(context) do
    broadcaster().notify(context)
  end

  def external_document_update(service, context) do
    broadcaster().external_document_update(service, context)
  end

  defp broadcaster, do: Application.get_env(:accent, :hook_broadcaster)
end
