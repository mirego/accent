defmodule Accent.Repo do
  use Ecto.Repo, otp_app: :accent, adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 30, max_page_size: 10_000
end
