defmodule Accent.Plugs.MovementContextParser do
  use Plug.Builder

  alias Accent.{Document, Repo}
  alias Accent.Scopes.Document, as: DocumentScope
  alias Movement.Context

  plug(:validate_params)
  plug(:assign_document_parser)
  plug(:assign_document_path)
  plug(:assign_document_format)
  plug(:assign_movement_context)
  plug(:assign_movement_document)
  plug(:assign_movement_entries)

  def validate_params(conn = %{params: %{"document_format" => _format, "file" => _file, "language" => _language}}, _), do: conn
  def validate_params(conn, _), do: conn |> send_resp(:unprocessable_entity, "file, language and document_format are required") |> halt

  def assign_document_parser(conn = %{params: %{"document_format" => document_format}}, _) do
    case Langue.parser_from_format(document_format) do
      {:ok, parser} -> assign(conn, :document_parser, parser)
      {:error, _reason} -> conn |> send_resp(:unprocessable_entity, "document_format is invalid") |> halt
    end
  end

  def assign_document_format(conn = %{params: %{"document_format" => format}}, _) do
    assign(conn, :document_format, format)
  end

  def assign_document_path(conn = %{params: %{"document_path" => path}}, _) when path !== "" and not is_nil(path) do
    assign(conn, :document_path, path)
  end

  def assign_document_path(conn = %{params: %{"file" => file}}, _) do
    assign(conn, :document_path, extract_path_from_filename(file.filename))
  end

  def assign_movement_context(conn, _) do
    assign(conn, :movement_context, %Context{})
  end

  def assign_movement_document(conn = %{assigns: %{project: project, movement_context: context, document_path: path, document_format: format}}, _opts) do
    Document
    |> DocumentScope.from_path(path)
    |> DocumentScope.from_project(project.id)
    |> Repo.one()
    |> case do
      nil ->
        context = Context.assign(context, :document, %Document{project_id: project.id, path: path, format: format})
        assign(conn, :movement_context, context)

      document ->
        document = %{document | format: format}
        context = Context.assign(context, :document, document)
        assign(conn, :movement_context, context)
    end
  end

  def assign_movement_entries(conn = %{assigns: %{movement_context: context}, params: %{"file" => file}}, _) do
    render = File.read!(file.path)

    conn
    |> parser_result(render)
    |> case do
      %{entries: entries, document: document} ->
        context =
          context
          |> Context.assign(:document, context.assigns[:document])
          |> Context.assign(:document_update, document && %{top_of_the_file_comment: document.top_of_the_file_comment, header: document.header})
          |> Map.put(:render, render)
          |> Map.put(:entries, entries)

        assign(conn, :movement_context, context)

      {:error, :invalid_file} ->
        conn
        |> send_resp(:unprocessable_entity, "file cannot be parsed")
        |> halt()
    end
  end

  defp parser_result(conn, render) do
    document = conn.assigns[:movement_context].assigns[:document]

    parser_input = %Langue.Formatter.SerializerResult{
      render: render,
      document: %Langue.Document{
        path: document.path,
        top_of_the_file_comment: document.top_of_the_file_comment,
        header: document.header
      }
    }

    conn.assigns[:document_parser].(parser_input)
  rescue
    _ -> {:error, :invalid_file}
  end

  defp extract_path_from_filename(filename) do
    Regex.replace(~r/(\w)(\.\w+)$/, filename, "\\1")
  end
end
