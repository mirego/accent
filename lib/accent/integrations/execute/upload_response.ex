defmodule Accent.IntegrationManager.Execute.UploadResponse do
  @moduledoc false

  def serialize({:ok, %{status: status, body: body}}), do: %{status_code: status, body: body}
  def serialize({:error, exception}) when is_exception(exception), do: %{error: Exception.message(exception)}
  def serialize(_), do: nil
end
