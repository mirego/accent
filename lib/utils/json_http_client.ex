defmodule Accent.Utils.JSONHTTPClient do
  @moduledoc false
  alias Tesla.Middleware

  @spec new(String.t(), Tesla.Client.middleware()) :: Tesla.Client.t()
  def new(base_url, auth_middleware) do
    Tesla.client([
      {Middleware.Timeout, [timeout: :infinity]},
      {Middleware.BaseUrl, base_url},
      auth_middleware,
      Middleware.DecodeJson,
      Middleware.EncodeJson,
      Middleware.Logger,
      Middleware.OpenTelemetry
    ])
  end
end
