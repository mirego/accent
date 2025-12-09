defmodule Accent.FormatController do
  use Phoenix.Controller, formats: [json: "View"]

  import Canary.Plugs

  alias Accent.Translation

  plug(Plug.Assign, %{canary_action: :format})
  plug(:load_resource, model: Accent.Project, id_name: "project_id")
  plug(Accent.Plugs.MovementContextParser)
  plug(:fetch_entries)
  plug(:fetch_formatted_content)

  @doc """
  Format a file

  ## Endpoint

    POST /format

  ### Required params
    - `project_id`
    - `file`
    - `document_format`

  ### Optional params
    - `order_by`
    - `inline_render`

  ### Response

    #### Success
    `200` - A file containing the rendered document.

    #### Error
    - `404` Unknown project id.
  """
  def format(%{query_params: %{"inline_render" => "true"}} = conn, _) do
    conn
    |> put_resp_header("content-type", "text/plain")
    |> send_resp(:ok, conn.assigns.render)
  end

  def format(conn, _) do
    file = Path.join([System.tmp_dir(), Accent.Utils.SecureRandom.urlsafe_base64(16)])

    :ok = File.write(file, conn.assigns.render)

    conn
    |> put_resp_header("content-disposition", "inline; filename=\"#{conn.params["document_path"]}\"")
    |> send_file(:ok, file)
  end

  defp fetch_entries(conn, _) do
    entries =
      Translation.maybe_natural_order_by(conn.assigns[:movement_context].entries, Map.get(conn.params, "order_by"))

    assign(conn, :entries, entries)
  end

  defp fetch_formatted_content(conn, _) do
    context = conn.assigns[:movement_context]
    document = context.assigns.document
    {:ok, serializer} = Langue.serializer_from_format(document.format)

    serialzier_input = %Langue.Formatter.ParserResult{
      entries: conn.assigns.entries,
      language: %Langue.Language{slug: conn.params["language"]},
      document: %Langue.Document{
        path: document.path,
        master_language: conn.params["language"],
        top_of_the_file_comment: document.top_of_the_file_comment,
        header: document.header
      }
    }

    try do
      assign(conn, :render, serializer.(serialzier_input).render)
    rescue
      _ -> assign(conn, :render, context.render)
    end
  end
end
