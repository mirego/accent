defmodule Accent.EmailView do
  use Phoenix.View, root: "lib/web/templates"

  import Accent.EmailViewConfigHelper
  import Accent.EmailViewStyleHelper

  def user_display_name(user) do
    Accent.User.name_with_fallback(user)
  end
end
