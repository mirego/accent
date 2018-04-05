defmodule Accent.Repo do
  use Ecto.Repo, otp_app: :accent
  use Scrivener, page_size: 30, max_page_size: 50
end
