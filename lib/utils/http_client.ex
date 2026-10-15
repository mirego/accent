defmodule Accent.HTTPClient do
  @moduledoc false

  @spec new(keyword()) :: Req.Request.t()
  def new(options \\ []) do
    [retry: false]
    |> Keyword.merge(Application.get_env(:accent, __MODULE__, []))
    |> Keyword.merge(options)
    |> Req.new()
    |> OpentelemetryReq.attach()
  end
end
