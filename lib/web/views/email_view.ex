defmodule Accent.EmailView do
  use Phoenix.View, root: "lib/web/templates"

  import Accent.EmailViewStyleHelper
  import Accent.EmailViewConfigHelper

  def user_display_name(user) do
    Accent.User.name_with_fallback(user)
  end
end
