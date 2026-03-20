defmodule Accent.GraphiQLController do
  use Phoenix.Controller, formats: []

  require EEx

  EEx.function_from_file(:defp, :template, "lib/web/templates/graphiql/index.html.eex")

  def index(conn, _params) do
    send_resp(conn, :ok, template())
  end
end
