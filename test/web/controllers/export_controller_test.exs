defmodule AccentTest.ExportController do
  use Accent.ConnCase

  alias Accent.Document
  alias Accent.Language
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.User
  alias Accent.Version

  @user %User{email: "test@test.com"}

  setup do
    user = Repo.insert!(@user)
    french_language = Repo.insert!(%Language{name: "french", slug: Ecto.UUID.generate()})
    project = Repo.insert!(%Project{main_color: "#f00", name: "My project"})

    revision = Repo.insert!(%Revision{language_id: french_language.id, project_id: project.id, master: true})

    {:ok, [user: user, project: project, revision: revision, language: french_language]}
  end

  test "export inline", %{conn: conn, project: project, revision: revision, language: language} do
    document = Repo.insert!(%Document{project_id: project.id, path: "test2", format: "json"})

    Repo.insert!(%Translation{
      revision_id: revision.id,
      key: "ok",
      corrected_text: "bar",
      proposed_text: "bar",
      document_id: document.id
    })

    params = %{
      inline_render: true,
      project_id: project.id,
      language: language.slug,
      document_format: document.format,
      document_path: document.path
    }

    response = get(conn, export_path(conn, [], params))

    assert get_resp_header(response, "content-type") == ["text/plain"]

    assert response.resp_body == """
           {
             "ok": "bar"
           }
           """
  end

  test "export basic", %{conn: conn, project: project, revision: revision, language: language} do
    document = Repo.insert!(%Document{project_id: project.id, path: "test2", format: "json"})

    Repo.insert!(%Translation{
      revision_id: revision.id,
      key: "ok",
      corrected_text: "bar",
      proposed_text: "bar",
      document_id: document.id
    })

    params = %{
      project_id: project.id,
      language: language.slug,
      document_format: document.format,
      document_path: document.path
    }

    response = get(conn, export_path(conn, [], params))

    assert get_resp_header(response, "content-disposition") == ["inline; filename=\"#{document.path}\""]

    assert response.resp_body == """
           {
             "ok": "bar"
           }
           """
  end

  test "export unknown language for the project", %{conn: conn, project: project} do
    document = Repo.insert!(%Document{project_id: project.id, path: "test2", format: "json"})
    language = Repo.insert!(%Language{name: "chinese", slug: Ecto.UUID.generate()})

    params = %{
      project_id: project.id,
      language: language.slug,
      document_format: document.format,
      document_path: document.path
    }

    response = get(conn, export_path(conn, [], params))

    assert response.status == 404
  end

  test "export document", %{conn: conn, project: project, revision: revision, language: language} do
    document = Repo.insert!(%Document{project_id: project.id, path: "test2", format: "json"})
    other_document = Repo.insert!(%Document{project_id: project.id, path: "test3", format: "json"})

    Repo.insert!(%Translation{
      revision_id: revision.id,
      key: "ok",
      corrected_text: "bar",
      proposed_text: "bar",
      document_id: document.id
    })

    Repo.insert!(%Translation{
      revision_id: revision.id,
      key: "test",
      corrected_text: "foo",
      proposed_text: "foo",
      document_id: other_document.id
    })

    params = %{
      project_id: project.id,
      language: language.slug,
      document_format: document.format,
      document_path: document.path
    }

    response = get(conn, export_path(conn, [], params))

    assert get_resp_header(response, "content-disposition") == ["inline; filename=\"#{document.path}\""]

    assert response.resp_body == """
           {
             "ok": "bar"
           }
           """
  end

  test "export unknown document", %{conn: conn, project: project, language: language} do
    params = %{project_id: project.id, language: language.slug, document_format: "json", document_path: "foo"}
    response = get(conn, export_path(conn, [], params))

    assert response.status == 404
  end

  test "export version", %{conn: conn, user: user, project: project, revision: revision, language: language} do
    version = Repo.insert!(%Version{project_id: project.id, user_id: user.id, name: "Current", tag: "master"})
    document = Repo.insert!(%Document{project_id: project.id, path: "test2", format: "json"})

    Repo.insert!(%Translation{
      revision_id: revision.id,
      key: "ok",
      corrected_text: "bar",
      proposed_text: "bar",
      document_id: document.id
    })

    Repo.insert!(%Translation{
      revision_id: revision.id,
      key: "test",
      corrected_text: "foo",
      proposed_text: "foo",
      document_id: document.id,
      version_id: version.id
    })

    params = %{
      version: "master",
      project_id: project.id,
      language: language.slug,
      document_format: document.format,
      document_path: document.path
    }

    response = get(conn, export_path(conn, [], params))

    assert response.resp_body == """
           {
             "test": "foo"
           }
           """
  end

  test "export without version", %{conn: conn, user: user, project: project, revision: revision, language: language} do
    version = Repo.insert!(%Version{project_id: project.id, user_id: user.id, name: "Current", tag: "master"})
    document = Repo.insert!(%Document{project_id: project.id, path: "test2", format: "json"})

    Repo.insert!(%Translation{
      revision_id: revision.id,
      key: "ok",
      corrected_text: "bar",
      proposed_text: "bar",
      document_id: document.id
    })

    Repo.insert!(%Translation{
      revision_id: revision.id,
      key: "test",
      corrected_text: "foo",
      proposed_text: "foo",
      document_id: document.id,
      version_id: version.id
    })

    params = %{
      project_id: project.id,
      language: language.slug,
      document_format: document.format,
      document_path: document.path
    }

    response = get(conn, export_path(conn, [], params))

    assert response.resp_body == """
           {
             "ok": "bar"
           }
           """
  end

  test "export with unknown version", %{conn: conn, project: project, language: language} do
    document = Repo.insert!(%Document{project_id: project.id, path: "test2", format: "json"})

    params = %{
      version: "foo",
      project_id: project.id,
      language: language.slug,
      document_format: document.format,
      document_path: document.path
    }

    response = get(conn, export_path(conn, [], params))

    assert response.status == 404
  end

  test "export with order", %{conn: conn, project: project, revision: revision, language: language} do
    document = Repo.insert!(%Document{project_id: project.id, path: "test2", format: "json"})

    Repo.insert!(%Translation{
      revision_id: revision.id,
      key: "ok",
      corrected_text: "bar",
      proposed_text: "bar",
      document_id: document.id
    })

    Repo.insert!(%Translation{
      revision_id: revision.id,
      key: "test",
      corrected_text: "foo",
      proposed_text: "foo",
      document_id: document.id
    })

    params = %{
      order_by: "key",
      project_id: project.id,
      language: language.slug,
      document_format: document.format,
      document_path: document.path
    }

    response = get(conn, export_path(conn, [], params))

    assert response.resp_body == """
           {
             "ok": "bar",
             "test": "foo"
           }
           """
  end

  test "export with default order", %{conn: conn, project: project, revision: revision, language: language} do
    document = Repo.insert!(%Document{project_id: project.id, path: "test2", format: "json"})

    Repo.insert!(%Translation{
      revision_id: revision.id,
      key: "ok",
      corrected_text: "bar",
      proposed_text: "bar",
      document_id: document.id,
      file_index: 2
    })

    Repo.insert!(%Translation{
      revision_id: revision.id,
      key: "test",
      corrected_text: "foo",
      proposed_text: "foo",
      document_id: document.id,
      file_index: 1
    })

    params = %{
      order_by: "",
      project_id: project.id,
      language: language.slug,
      document_format: document.format,
      document_path: document.path
    }

    response = get(conn, export_path(conn, [], params))

    assert response.resp_body == """
           {
             "test": "foo",
             "ok": "bar"
           }
           """
  end

  if Langue.Formatter.Rails.enabled?() do
    test "export with language overrides", %{conn: conn, project: project, revision: revision} do
      revision = Repo.update!(Ecto.Changeset.change(revision, %{slug: "testtest"}))
      document = Repo.insert!(%Document{project_id: project.id, path: "test2", format: "rails_yml"})

      Repo.insert!(%Translation{
        revision_id: revision.id,
        key: "ok",
        corrected_text: "bar",
        proposed_text: "bar",
        document_id: document.id,
        file_index: 2
      })

      Repo.insert!(%Translation{
        revision_id: revision.id,
        key: "test",
        corrected_text: "foo",
        proposed_text: "foo",
        document_id: document.id,
        file_index: 1
      })

      params = %{
        order_by: "",
        project_id: project.id,
        language: revision.slug,
        document_format: document.format,
        document_path: document.path
      }

      response = get(conn, export_path(conn, [], params))

      assert response.resp_body == """
             "testtest":
               "test": "foo"
               "ok": "bar"
             """
    end
  end

  test "export with plurals and android formatter", %{
    conn: conn,
    project: project,
    revision: revision,
    language: language
  } do
    document = Repo.insert!(%Document{project_id: project.id, path: "test", format: "android_xml"})

    Repo.insert!(%Translation{
      revision_id: revision.id,
      key: "days.one",
      corrected_text: "bar",
      proposed_text: "bar",
      plural: true,
      document_id: document.id,
      file_index: 2
    })

    Repo.insert!(%Translation{
      revision_id: revision.id,
      key: "days.other",
      corrected_text: "foo",
      proposed_text: "foo",
      plural: true,
      document_id: document.id,
      file_index: 1
    })

    params = %{
      order_by: "",
      project_id: project.id,
      language: language.slug,
      document_format: document.format,
      document_path: document.path
    }

    response = get(conn, export_path(conn, [], params))

    assert response.resp_body == """
           <?xml version="1.0" encoding="utf-8"?>
           <resources>
             <plurals name="days">
               <item quantity="other">foo</item>
               <item quantity="one">bar</item>
             </plurals>
           </resources>
           """
  end
end
