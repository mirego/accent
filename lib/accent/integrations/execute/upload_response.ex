defmodule Accent.IntegrationManager.Execute.UploadResponse do
  @moduledoc false

  def serialize({:ok, %{status_code: status_code, body: body}}), do: %{status_code: status_code, body: body}
  def serialize({:error, %{reason: reason}}), do: %{error: inspect(reason)}
  def serialize(_), do: nil
end
