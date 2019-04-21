defmodule AccentTest.PeekController do
  use Accent.ConnCase

  import Mox
  setup :verify_on_exit!

  alias Accent.{
    AccessToken,
    Collaborator,
    Document,
    Language,
    Project,
    Repo,
    Revision,
    Translation,
    User
  }

  @user %User{email: "test@test.com"}

  def file(filename \\ "simple.json") do
    %Plug.Upload{content_type: "application/json", filename: filename, path: "test/support/formatter/json/simple.json"}
  end

  setup do
    user = Repo.insert!(@user)
    access_token = %AccessToken{user_id: user.id, token: "test-token"} |> Repo.insert!()
    french_language = %Language{name: "french", slug: Ecto.UUID.generate()} |> Repo.insert!()
    project = %Project{main_color: "#f00", name: "My project"} |> Repo.insert!()

    %Collaborator{project_id: project.id, user_id: user.id, role: "admin"} |> Repo.insert!()
    revision = %Revision{language_id: french_language.id, project_id: project.id, master: true} |> Repo.insert!()

    {:ok, [access_token: access_token, user: user, project: project, revision: revision, language: french_language]}
  end

  test "merge", %{access_token: access_token, conn: conn, project: project, revision: revision, language: language} do
    document = %Document{project_id: project.id, path: "test2", format: "json"} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "test", conflicted: true, corrected_text: "initial", proposed_text: "initial", document_id: document.id} |> Repo.insert!()

    body = %{file: file(), project_id: project.id, language: language.slug, document_format: document.format, document_path: document.path}

    Accent.Hook.BroadcasterMock
    |> expect(:notify, fn %{event: "peek_merge"} -> :ok end)

    response =
      conn
      |> put_req_header("authorization", "Bearer #{access_token.token}")
      |> post(peek_add_translations_path(conn, :merge), body)
      |> json_response(200)

    assert get_in(response, ["data", "stats", revision.id]) == %{"merge_on_proposed" => 1}

    assert get_in(response, ["data", "operations", revision.id]) == [
             %{
               "action" => "merge_on_proposed",
               "key" => "test",
               "previous-text" => "initial",
               "text" => "F"
             }
           ]
  end

  test "merge old route", %{access_token: access_token, conn: conn, project: project, revision: revision, language: language} do
    document = %Document{project_id: project.id, path: "test2", format: "json"} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "test", conflicted: true, corrected_text: "initial", proposed_text: "initial", document_id: document.id} |> Repo.insert!()

    body = %{file: file(), project_id: project.id, language: language.slug, document_format: document.format, document_path: document.path}

    Accent.Hook.BroadcasterMock
    |> expect(:notify, fn %{event: "peek_merge"} -> :ok end)

    response =
      conn
      |> put_req_header("authorization", "Bearer #{access_token.token}")
      |> post(peek_merge_path(conn, :merge), body)
      |> json_response(200)

    assert get_in(response, ["data", "stats", revision.id]) == %{"merge_on_proposed" => 1}

    assert get_in(response, ["data", "operations", revision.id]) == [
             %{
               "action" => "merge_on_proposed",
               "key" => "test",
               "previous-text" => "initial",
               "text" => "F"
             }
           ]
  end

  test "merge passive", %{access_token: access_token, conn: conn, project: project, revision: revision, language: language} do
    document = %Document{project_id: project.id, path: "test2", format: "json"} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "test", conflicted: false, corrected_text: "initial", proposed_text: "initial", document_id: document.id} |> Repo.insert!()

    body = %{file: file(), merge_type: "passive", project_id: project.id, language: language.slug, document_format: document.format, document_path: document.path}

    Accent.Hook.BroadcasterMock
    |> expect(:notify, fn %{event: "peek_merge"} -> :ok end)

    response =
      conn
      |> put_req_header("authorization", "Bearer #{access_token.token}")
      |> post(peek_merge_path(conn, :merge), body)
      |> json_response(200)

    assert get_in(response, ["data", "stats"]) == %{}
    assert get_in(response, ["data", "operations"]) == %{}
  end

  test "merge force", %{access_token: access_token, conn: conn, project: project, revision: revision, language: language} do
    document = %Document{project_id: project.id, path: "test2", format: "json"} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "test", conflicted: false, corrected_text: "initial", proposed_text: "initial", document_id: document.id} |> Repo.insert!()

    body = %{file: file(), merge_type: "force", project_id: project.id, language: language.slug, document_format: document.format, document_path: document.path}

    Accent.Hook.BroadcasterMock
    |> expect(:notify, fn %{event: "peek_merge"} -> :ok end)

    response =
      conn
      |> put_req_header("authorization", "Bearer #{access_token.token}")
      |> post(peek_merge_path(conn, :merge), body)
      |> json_response(200)

    assert get_in(response, ["data", "stats", revision.id]) == %{"merge_on_proposed_force" => 1}

    assert get_in(response, ["data", "operations", revision.id]) == [
             %{
               "action" => "merge_on_proposed_force",
               "key" => "test",
               "previous-text" => "initial",
               "text" => "F"
             }
           ]
  end

  test "sync", %{access_token: access_token, conn: conn, project: project, revision: revision, language: language} do
    document = %Document{project_id: project.id, path: "test2", format: "json"} |> Repo.insert!()
    %Translation{revision_id: revision.id, key: "test", conflicted: true, corrected_text: "initial", proposed_text: "initial", document_id: document.id} |> Repo.insert!()

    body = %{file: file(), project_id: project.id, language: language.slug, document_format: document.format, document_path: document.path}

    Accent.Hook.BroadcasterMock
    |> expect(:notify, fn %{event: "peek_sync"} -> :ok end)

    response =
      conn
      |> put_req_header("authorization", "Bearer #{access_token.token}")
      |> post(peek_sync_path(conn, :sync), body)
      |> json_response(200)

    assert get_in(response, ["data", "stats", revision.id]) == %{"conflict_on_proposed" => 1, "new" => 2}

    assert get_in(response, ["data", "operations", revision.id]) == [
             %{
               "action" => "conflict_on_proposed",
               "key" => "test",
               "previous-text" => "initial",
               "text" => "F"
             },
             %{
               "action" => "new",
               "key" => "test2",
               "previous-text" => "",
               "text" => "D"
             },
             %{
               "action" => "new",
               "key" => "test3",
               "previous-text" => "",
               "text" => "New history please"
             }
           ]
  end
end
