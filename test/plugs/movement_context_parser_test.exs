defmodule AccentTest.Plugs.MovementContextParser do
  use Accent.RepoCase
  use Plug.Test

  alias Accent.{
    Document,
    Language,
    Plugs.MovementContextParser,
    ProjectCreator,
    Repo,
    User
  }

  def file(filename \\ "simple.json") do
    %Plug.Upload{content_type: "application/json", filename: filename, path: "test/support/formatter/json/simple.json"}
  end

  def file_with_header do
    %Plug.Upload{content_type: "plain/text", filename: "simple.gettext", path: "test/support/formatter/gettext/simple.po"}
  end

  def invalid_file do
    %Plug.Upload{content_type: "application/json", filename: "simple.json", path: "test/support/invalid_file.json"}
  end

  @user %User{email: "test@test.com"}
  setup do
    user = Repo.insert!(@user)
    language = Repo.insert!(%Language{name: "English", slug: Ecto.UUID.generate()})
    {:ok, project} = ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)
    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()
    document = Repo.insert!(%Document{project_id: project.id, path: "test", format: "json"})

    {:ok, [project: project, document: document, revision: revision, language: language, user: user]}
  end

  test "with no params" do
    conn =
      :get
      |> conn("/foo")
      |> MovementContextParser.call([])

    assert conn.status == 422
    assert conn.resp_body == "file, language and document_format are required"
    assert conn.state == :sent
  end

  test "with missing file" do
    conn =
      :get
      |> conn("/foo", %{document_path: "test.json", document_format: "json", language: "fr"})
      |> MovementContextParser.call([])

    assert conn.status == 422
    assert conn.resp_body == "file, language and document_format are required"
    assert conn.state == :sent
  end

  test "fetch document path with only file param", %{project: project} do
    conn =
      :get
      |> conn("/foo", %{document_format: "json", file: file("foo.json"), language: "fr"})
      |> assign(:project, project)
      |> MovementContextParser.call([])

    assert conn.assigns[:document_path] == "foo"
    assert conn.state == :unset
  end

  test "fetch document path with file param containing multiple dots", %{project: project} do
    conn =
      :get
      |> conn("/foo", %{document_path: "admin.common.test", document_format: "json", file: file("foo.json"), language: "fr"})
      |> assign(:project, project)
      |> MovementContextParser.call([])

    assert conn.assigns[:document_path] == "admin.common.test"
    assert conn.state == :unset
  end

  test "fetch document path with file param containing no dots", %{project: project} do
    conn =
      :get
      |> conn("/foo", %{document_path: "admin", document_format: "json", file: file("foo.json"), language: "fr"})
      |> assign(:project, project)
      |> MovementContextParser.call([])

    assert conn.assigns[:document_path] == "admin"
    assert conn.state == :unset
  end

  test "fetch document parser", %{project: project} do
    conn =
      :get
      |> conn("/foo", %{document_path: "test.json", document_format: "json", file: file(), language: "fr"})
      |> assign(:project, project)
      |> MovementContextParser.call([])

    assert conn.assigns[:document_parser] == (&Langue.Formatter.Json.parse/1)
    assert conn.state == :unset
  end

  test "fetch invalid document parser", %{project: project} do
    conn =
      :get
      |> conn("/foo", %{document_path: "test.json", document_format: "UNKOWN", file: file(), language: "fr"})
      |> assign(:project, project)
      |> MovementContextParser.call([])

    assert conn.resp_body == "document_format is invalid"
    assert conn.status == 422
    assert conn.state == :sent
  end

  test "fetch document render", %{project: project} do
    conn =
      :get
      |> conn("/foo", %{document_path: "test.json", document_format: "json", file: file(), language: "fr"})
      |> assign(:project, project)
      |> MovementContextParser.call([])

    context =
      conn.assigns
      |> Map.get(:movement_context)

    assert context.render == File.read!(file().path)
    assert conn.state == :unset
  end

  test "fetch new document resource", %{project: project} do
    conn =
      :get
      |> conn("/foo", %{document_path: "hello", document_format: "json", file: file(), language: "fr"})
      |> assign(:project, project)
      |> MovementContextParser.call([])

    context =
      conn.assigns
      |> Map.get(:movement_context)

    assert context.assigns[:document] == %Document{path: "hello", format: "json", project_id: project.id}
    assert conn.state == :unset
  end

  test "assign document top_of_the_file_comment and header", %{project: project} do
    conn =
      :get
      |> conn("/foo", %{document_path: "hello", document_format: "gettext", file: file_with_header(), language: "fr"})
      |> assign(:project, project)
      |> MovementContextParser.call([])

    context =
      conn.assigns
      |> Map.get(:movement_context)

    assert context.assigns[:document] == %Document{
             project_id: project.id,
             path: "hello",
             format: "gettext"
           }

    assert context.assigns[:document_update] == %{
             top_of_the_file_comment:
               "## Do not add, change, or remove `msgid`s manually here as\n## they're tied to the ones in the corresponding POT file\n## (with the same domain).\n##\n## Use `mix gettext.extract --merge` or `mix gettext.merge`\n## to merge POT files into PO files.",
             header: "\nLanguage: fr\n"
           }

    assert conn.state == :unset
  end

  test "fetch existing document resource", %{project: project, language: language, document: document} do
    conn =
      :get
      |> conn("/foo", %{document_path: document.path, document_format: "json", file: file(), language: language.slug})
      |> assign(:project, project)
      |> MovementContextParser.call([])

    context =
      conn.assigns
      |> Map.get(:movement_context)

    assert context.assigns[:document].id == document.id
    assert conn.state == :unset
  end

  test "fetch entries", %{project: project} do
    conn =
      :get
      |> conn("/foo", %{document_path: "test.json", document_format: "json", file: file(), language: "fr"})
      |> assign(:project, project)
      |> MovementContextParser.call([])

    context =
      conn.assigns
      |> Map.get(:movement_context)

    assert context.entries == [
             %Langue.Entry{index: 1, key: "test", value: "F"},
             %Langue.Entry{index: 2, key: "test2", value: "D"},
             %Langue.Entry{index: 3, key: "test3", value: "New history please"}
           ]
  end

  test "invalid file", %{project: project} do
    conn =
      :get
      |> conn("/foo", %{document_path: "test.json", document_format: "json", file: invalid_file(), language: "fr"})
      |> assign(:project, project)
      |> MovementContextParser.call([])

    assert conn.state == :sent
    assert conn.status == 422
    assert conn.resp_body == "file cannot be parsed"
  end
end
