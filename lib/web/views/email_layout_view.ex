defmodule Accent.EmailLayoutView do
  use Phoenix.View, root: "lib/web/templates"

  import Accent.Router.Helpers, only: [static_url: 2]
  import Accent.EmailViewStyleHelper
  import Accent.EmailViewConfigHelper

  def logo_url do
    Accent.Endpoint
    |> static_url("/static/images/accent.png")
    |> String.replace(~r/:\d+/, "")
  end
end
