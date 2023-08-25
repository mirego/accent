defmodule Accent.EmailLayoutView do
  use Phoenix.View, root: "lib/web/templates"

  import Accent.EmailViewConfigHelper
  import Accent.EmailViewStyleHelper
  import Accent.Router.Helpers, only: [static_url: 2]

  def logo_url do
    Accent.Endpoint
    |> static_url("/static/images/accent.png")
    |> String.replace(~r/:\d+/, "")
  end
end
