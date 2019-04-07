defmodule Accent.Repo do
  use Ecto.Repo, otp_app: :accent, adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 30, max_page_size: 10_000

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, Application.get_env(:accent, Accent.Repo)[:url])}
  end
end
