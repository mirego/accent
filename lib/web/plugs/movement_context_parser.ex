defmodule Accent.Plugs.MovementContextParser do
  @moduledoc false
  use Plug.Builder

  alias Accent.Document
  alias Accent.Repo
  alias Accent.Scopes.Document, as: DocumentScope
  alias Accent.Scopes.Version, as: VersionScope
  alias Accent.Version
  alias Movement.Context

  @non_printable_characters [
    <<255, 240>>,
    <<255, 241>>,
    <<255, 242>>,
    <<255, 243>>,
    <<255, 244>>,
    <<255, 245>>,
    <<255, 246>>,
    <<255, 247>>,
    <<255, 248>>,
    <<255, 240>>,
    <<255, 16>>,
    <<255, 17>>,
    <<255, 18>>,
    <<255, 19>>,
    <<255, 20>>,
    <<255, 250>>,
    <<255, 251>>,
    <<255, 252>>,
    <<255, 254>>,
    <<255, 255>>
  ]

  @replacement_character "�"

  plug(:validate_params)
  plug(:assign_document_format)
  plug(:assign_document_parser)
  plug(:assign_document_path)
  plug(:assign_version)
  plug(:assign_movement_context)
  plug(:assign_movement_document)
  plug(:assign_movement_version)
  plug(:assign_movement_entries)

  def validate_params(%{params: %{"document_format" => _format, "file" => _file, "language" => _language}} = conn, _),
    do: conn

  def validate_params(conn, _),
    do: conn |> send_resp(:unprocessable_entity, "file, language and document_format are required") |> halt()

  def assign_document_parser(%{assigns: %{document_format: document_format}} = conn, _) do
    case Langue.parser_from_format(document_format) do
      {:ok, parser} -> assign(conn, :document_parser, parser)
      {:error, _reason} -> conn |> send_resp(:unprocessable_entity, "document_format is invalid") |> halt()
    end
  end

  def assign_document_format(%{params: %{"document_format" => format}} = conn, _) do
    assign(conn, :document_format, String.downcase(format))
  end

  def assign_document_path(%{params: %{"document_path" => path}} = conn, _) when path !== "" and not is_nil(path) do
    assign(conn, :document_path, path)
  end

  def assign_document_path(%{params: %{"file" => file}} = conn, _) do
    assign(conn, :document_path, extract_path_from_filename(file.filename))
  end

  def assign_version(%{assigns: %{project: project}, params: %{"version" => version}} = conn, _) do
    Version
    |> VersionScope.from_project(project.id)
    |> VersionScope.from_tag(version)
    |> Repo.one()
    |> case do
      nil ->
        conn
        |> send_resp(:not_found, ~s(unknown version "#{version}"))
        |> halt()

      version ->
        assign(conn, :version, version)
    end
  end

  def assign_version(conn, _) do
    assign(conn, :version, nil)
  end

  def assign_movement_context(conn, _) do
    assign(conn, :movement_context, Context.assign(%Context{}, :project, conn.assigns[:project]))
  end

  def assign_movement_version(%{assigns: %{version: version, movement_context: context}} = conn, _opts) do
    context = Context.assign(context, :version, version)
    assign(conn, :movement_context, context)
  end

  def assign_movement_document(
        %{assigns: %{project: project, movement_context: context, document_path: path, document_format: format}} = conn,
        _opts
      ) do
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

  def assign_movement_entries(%{assigns: %{movement_context: context}, params: %{"file" => file}} = conn, _) do
    raw = File.read!(file.path)
    render = if String.printable?(raw), do: raw, else: unicode_only(raw)

    conn
    |> parser_result(render)
    |> case do
      %{entries: entries, document: document} ->
        context =
          context
          |> Context.assign(:document, context.assigns[:document])
          |> Context.assign(
            :document_update,
            document && %{top_of_the_file_comment: document.top_of_the_file_comment, header: document.header}
          )
          |> Map.put(:render, render)
          |> Map.put(:entries, entries)

        assign(conn, :movement_context, context)

      {:error, :invalid_file} ->
        conn
        |> send_resp(:unprocessable_entity, "file cannot be parsed")
        |> halt()
    end
  end

  def to_entries(document, render, parser) do
    parser_input = %Langue.Formatter.SerializerResult{
      render: render,
      document: %Langue.Document{
        path: document.path,
        top_of_the_file_comment: document.top_of_the_file_comment,
        header: document.header
      }
    }

    parser.(parser_input)
  rescue
    _ -> {:error, :invalid_file}
  end

  defp parser_result(%{assigns: %{document_parser: parser, movement_context: context}}, render) do
    to_entries(
      context.assigns[:document],
      render,
      parser
    )
  end

  def extract_path_from_filename(filename) do
    Regex.replace(~r/(\w)(\.\w+)$/, filename, "\\1")
  end

  def unicode_only(string, new_string \\ "")

  def unicode_only(<<head::binary-size(2)>> <> tail, new_string) when head in @non_printable_characters do
    unicode_only(tail, @replacement_character <> new_string)
  end

  def unicode_only(<<head::binary-size(1)>> <> tail, new_string) do
    printable_head? = String.printable?(head)
    printable_tail? = String.printable?(tail)

    cond do
      printable_head? and printable_tail? ->
        String.reverse(new_string) <> head <> tail

      printable_head? ->
        unicode_only(tail, head <> new_string)

      true ->
        unicode_only(tail, new_string)
    end
  end

  def unicode_only("", new_string), do: String.trim_leading(String.reverse(new_string), @replacement_character)
end
