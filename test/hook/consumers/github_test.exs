defmodule AccentTest.Hook.Consumers.GitHub do
  use Accent.RepoCase

  alias Accent.Hook.Consumers.GitHub, as: Consumer
  alias Accent.Hook.Consumers.GitHub.FileServerMock
  alias Accent.{Document, Integration, Language, Operation, ProjectCreator, Repo, Revision, Translation, User, Version}
  alias Ecto.UUID

  import Ecto.Query

  import Mox
  setup :verify_on_exit!

  setup do
    user = Repo.insert!(%User{email: "test@test.com"})
    language = Repo.insert!(%Language{name: "English", slug: UUID.generate()})
    {:ok, project} = ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)
    document = Repo.insert!(%Document{project_id: project.id, path: "admin", format: "json"})

    [project: project, document: document, user: user]
  end

  def gettext_file do
    Base.encode64(~S(
      msgid "key"
      msgstr "value"
      ))
  end

  def json_file do
    Base.encode64(~S(
      {
        "key": "value"
      }
      ))
  end

  test "sync default version on default_ref develop", %{project: project, user: user} do
    config =
      %{
        "files" => [
          %{
            "format" => "gettext",
            "language" => "fr",
            "source" => "priv/fr/**/*.po"
          }
        ]
      }
      |> Jason.encode!()
      |> Base.encode64()

    FileServerMock
    |> expect(:get_path, fn "accent/test-repo/contents/accent.json?ref=develop", [{"Authorization", "token 1234"}] ->
      {:ok, %{body: %{"content" => config}}}
    end)
    |> expect(:get_path, fn "accent/test-repo/git/trees/develop?recursive=1", [{"Authorization", "token 1234"}] ->
      {:ok,
       %{
         body: %{
           "tree" => [
             %{"path" => "accent.json", "type" => "blob", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/1"},
             %{"path" => "Dockerfile", "type" => "blob", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/2"},
             %{"path" => "priv/fr", "type" => "tree", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/3"},
             %{"path" => "priv/fr", "type" => "tree", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/4"},
             %{"path" => "priv/fr/admin.po", "type" => "blob", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/5"},
             %{"path" => "priv/en/admin.po", "type" => "blob", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/6"}
           ]
         }
       }}
    end)
    |> expect(:get_path, fn "https://api.github.com/repos/accent/test-repo/git/blobs/5", [{"Authorization", "token 1234"}] ->
      {:ok, %{body: %{"content" => gettext_file()}}}
    end)

    data = %{default_ref: "develop", repository: "accent/test-repo", token: "1234"}
    Repo.insert!(%Integration{project_id: project.id, user_id: user.id, service: "github", data: data})

    event = %Accent.Hook.Context{
      project: project,
      event: "push",
      payload: %{
        default_ref: data.default_ref,
        ref: "refs/heads/develop",
        repository: data.repository,
        token: data.token
      }
    }

    Consumer.handle_events([event], nil, [])

    batch_operation =
      Operation
      |> where([o], o.batch == true)
      |> Repo.one()

    operation =
      Operation
      |> where([o], o.batch == false)
      |> Repo.one()

    translation =
      Translation
      |> where([t], t.key == ^"key")
      |> Repo.one()

    assert batch_operation.action === "sync"
    assert operation.action === "new"
    assert operation.translation_id === translation.id
    assert translation.proposed_text === "value"
  end

  test "sync with json file", %{project: project, user: user} do
    config =
      %{
        "files" => [
          %{
            "format" => "json",
            "language" => "fr",
            "source" => "priv/fr/**/*.json"
          }
        ]
      }
      |> Jason.encode!()
      |> Base.encode64()

    FileServerMock
    |> expect(:get_path, fn "accent/test-repo/contents/accent.json?ref=develop", [{"Authorization", "token 1234"}] ->
      {:ok, %{body: %{"content" => config}}}
    end)
    |> expect(:get_path, fn "accent/test-repo/git/trees/develop?recursive=1", [{"Authorization", "token 1234"}] ->
      {:ok,
       %{
         body: %{
           "tree" => [
             %{"path" => "accent.json", "type" => "blob", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/1"},
             %{"path" => "Dockerfile", "type" => "blob", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/2"},
             %{"path" => "priv/fr", "type" => "tree", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/3"},
             %{"path" => "priv/fr", "type" => "tree", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/4"},
             %{"path" => "priv/fr/admin.json", "type" => "blob", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/5"},
             %{"path" => "priv/en/admin.json", "type" => "blob", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/6"}
           ]
         }
       }}
    end)
    |> expect(:get_path, fn "https://api.github.com/repos/accent/test-repo/git/blobs/5", [{"Authorization", "token 1234"}] ->
      {:ok, %{body: %{"content" => json_file()}}}
    end)

    data = %{default_ref: "develop", repository: "accent/test-repo", token: "1234"}
    Repo.insert!(%Integration{project_id: project.id, user_id: user.id, service: "github", data: data})

    event = %Accent.Hook.Context{
      project: project,
      event: "push",
      payload: %{
        default_ref: data.default_ref,
        ref: "refs/heads/develop",
        repository: data.repository,
        token: data.token
      }
    }

    Consumer.handle_events([event], nil, [])

    batch_operation =
      Operation
      |> where([o], o.batch == true)
      |> Repo.one()

    operation =
      Operation
      |> where([o], o.batch == false)
      |> Repo.one()

    translation =
      Translation
      |> where([t], t.key == ^"key")
      |> Repo.one()

    assert batch_operation.action === "sync"
    assert operation.action === "new"
    assert operation.translation_id === translation.id
    assert translation.proposed_text === "value"
  end

  test "dont sync when default ref does not match", %{project: project, user: user} do
    data = %{default_ref: "master", repository: "accent/test-repo", token: "1234"}
    Repo.insert!(%Integration{project_id: project.id, user_id: user.id, service: "github", data: data})

    event = %Accent.Hook.Context{
      project: project,
      event: "push",
      payload: %{
        default_ref: data.default_ref,
        ref: "refs/heads/feature/my-feature",
        repository: data.repository,
        token: data.token
      }
    }

    Consumer.handle_events([event], nil, [])

    translation =
      Translation
      |> where([t], t.key == ^"key")
      |> Repo.one()

    assert translation === nil
  end

  test "sync tag version on matching ref tag", %{project: project, user: user} do
    config =
      %{
        "files" => [
          %{
            "format" => "gettext",
            "language" => "fr",
            "source" => "priv/fr/**/*.po"
          }
        ]
      }
      |> Jason.encode!()
      |> Base.encode64()

    FileServerMock
    |> expect(:get_path, fn "accent/test-repo/contents/accent.json?ref=v1.0.0", [{"Authorization", "token 1234"}] ->
      {:ok, %{body: %{"content" => config}}}
    end)
    |> expect(:get_path, fn "accent/test-repo/git/trees/v1.0.0?recursive=1", [{"Authorization", "token 1234"}] ->
      {:ok,
       %{
         body: %{
           "tree" => [
             %{"path" => "accent.json", "type" => "blob", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/1"},
             %{"path" => "Dockerfile", "type" => "blob", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/2"},
             %{"path" => "priv/fr", "type" => "tree", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/3"},
             %{"path" => "priv/fr", "type" => "tree", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/4"},
             %{"path" => "priv/fr/admin.po", "type" => "blob", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/5"},
             %{"path" => "priv/en/admin.po", "type" => "blob", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/6"}
           ]
         }
       }}
    end)
    |> expect(:get_path, fn "https://api.github.com/repos/accent/test-repo/git/blobs/5", [{"Authorization", "token 1234"}] ->
      {:ok, %{body: %{"content" => gettext_file()}}}
    end)

    version = Repo.insert!(%Version{project_id: project.id, user_id: user.id, tag: "v1.0.0", name: "First release"})
    data = %{default_ref: "master", repository: "accent/test-repo", token: "1234"}
    Repo.insert!(%Integration{project_id: project.id, user_id: user.id, service: "github", data: data})

    event = %Accent.Hook.Context{
      project: project,
      event: "push",
      payload: %{
        default_ref: data.default_ref,
        ref: "refs/tags/v1.0.0",
        repository: data.repository,
        token: data.token
      }
    }

    Consumer.handle_events([event], nil, [])

    batch_operation =
      Operation
      |> where([o], o.batch == true and o.version_id == ^version.id)
      |> Repo.one()

    operation =
      Operation
      |> where([o], o.batch == false and o.version_id == ^version.id)
      |> Repo.one()

    translation =
      Translation
      |> where([t], t.key == ^"key" and t.version_id == ^version.id)
      |> Repo.one()

    assert batch_operation.action === "sync"
    assert operation.action === "new"
    assert operation.translation_id === translation.id
    assert translation.proposed_text === "value"
  end

  test "add translations default version on default_ref develop", %{project: project, document: document, user: user} do
    language_slug = UUID.generate()
    language = Repo.insert!(%Language{name: "Other french", slug: language_slug})
    revision = Repo.insert!(%Revision{project_id: project.id, master: false, language: language})
    translation = Repo.insert!(%Translation{revision_id: revision.id, document_id: document.id, key: "key", proposed_text: "a", corrected_text: "a"})

    config =
      %{
        "files" => [
          %{
            "format" => "gettext",
            "language" => "fr",
            "source" => "priv/fr/**/*.po",
            "target" => "priv/%slug%/**/%document_path%.po"
          }
        ]
      }
      |> Jason.encode!()
      |> Base.encode64()

    FileServerMock
    |> expect(:get_path, fn "accent/test-repo/contents/accent.json?ref=develop", [{"Authorization", "token 1234"}] ->
      {:ok, %{body: %{"content" => config}}}
    end)
    |> expect(:get_path, fn "accent/test-repo/git/trees/develop?recursive=1", [{"Authorization", "token 1234"}] ->
      {:ok,
       %{
         body: %{
           "tree" => [
             %{"path" => "accent.json", "type" => "blob", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/1"},
             %{"path" => "Dockerfile", "type" => "blob", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/2"},
             %{"path" => "priv/#{language_slug}", "type" => "tree", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/4"},
             %{"path" => "priv/#{language_slug}/admin.po", "type" => "blob", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/6"}
           ]
         }
       }}
    end)
    |> expect(:get_path, fn "https://api.github.com/repos/accent/test-repo/git/blobs/6", [{"Authorization", "token 1234"}] ->
      {:ok, %{body: %{"content" => gettext_file()}}}
    end)

    data = %{default_ref: "develop", repository: "accent/test-repo", token: "1234"}
    Repo.insert!(%Integration{project_id: project.id, user_id: user.id, service: "github", data: data})

    event = %Accent.Hook.Context{
      project: project,
      event: "push",
      payload: %{
        default_ref: data.default_ref,
        ref: "refs/heads/develop",
        repository: data.repository,
        token: data.token
      }
    }

    Consumer.handle_events([event], nil, [])

    batch_operation =
      Operation
      |> where([o], o.batch == true)
      |> Repo.one()

    operation =
      Operation
      |> where([o], o.batch == false)
      |> Repo.one()

    updated_translation =
      Translation
      |> where([t], t.key == ^"key")
      |> Repo.one()

    assert batch_operation.action === "merge"
    assert operation.action === "merge_on_proposed"
    assert operation.translation_id === translation.id

    assert operation.previous_translation === %Accent.PreviousTranslation{
             corrected_text: "a",
             proposed_text: "a",
             value_type: "string"
           }

    assert updated_translation.conflicted_text === "a"
    assert updated_translation.proposed_text === "value"
  end

  test "add translations with language overrides", %{project: project, document: document, user: user} do
    language_override = UUID.generate()
    language_slug = UUID.generate()
    language = Repo.insert!(%Language{name: "Other french", slug: language_slug})
    revision = Repo.insert!(%Revision{project_id: project.id, master: false, language: language, slug: language_override})
    translation = Repo.insert!(%Translation{revision_id: revision.id, document_id: document.id, key: "key", proposed_text: "a", corrected_text: "a"})

    config =
      %{
        "files" => [
          %{
            "format" => "gettext",
            "language" => "fr",
            "source" => "priv/fr/**/*.po",
            "target" => "priv/%slug%/**/%document_path%.po"
          }
        ]
      }
      |> Jason.encode!()
      |> Base.encode64()

    FileServerMock
    |> expect(:get_path, fn "accent/test-repo/contents/accent.json?ref=develop", [{"Authorization", "token 1234"}] ->
      {:ok, %{body: %{"content" => config}}}
    end)
    |> expect(:get_path, fn "accent/test-repo/git/trees/develop?recursive=1", [{"Authorization", "token 1234"}] ->
      {:ok,
       %{
         body: %{
           "tree" => [
             %{"path" => "accent.json", "type" => "blob", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/1"},
             %{"path" => "Dockerfile", "type" => "blob", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/2"},
             %{"path" => "priv/#{language_override}", "type" => "tree", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/4"},
             %{"path" => "priv/#{language_override}/admin.po", "type" => "blob", "url" => "https://api.github.com/repos/accent/test-repo/git/blobs/6"}
           ]
         }
       }}
    end)
    |> expect(:get_path, fn "https://api.github.com/repos/accent/test-repo/git/blobs/6", [{"Authorization", "token 1234"}] ->
      {:ok, %{body: %{"content" => gettext_file()}}}
    end)

    data = %{default_ref: "develop", repository: "accent/test-repo", token: "1234"}
    Repo.insert!(%Integration{project_id: project.id, user_id: user.id, service: "github", data: data})

    event = %Accent.Hook.Context{
      project: project,
      event: "push",
      payload: %{
        default_ref: data.default_ref,
        ref: "refs/heads/develop",
        repository: data.repository,
        token: data.token
      }
    }

    Consumer.handle_events([event], nil, [])

    batch_operation =
      Operation
      |> where([o], o.batch == true)
      |> Repo.one()

    operation =
      Operation
      |> where([o], o.batch == false)
      |> Repo.one()

    updated_translation =
      Translation
      |> where([t], t.key == ^"key")
      |> Repo.one()

    assert batch_operation.action === "merge"
    assert operation.action === "merge_on_proposed"
    assert operation.translation_id === translation.id

    assert operation.previous_translation === %Accent.PreviousTranslation{
             corrected_text: "a",
             proposed_text: "a",
             value_type: "string"
           }

    assert updated_translation.conflicted_text === "a"
    assert updated_translation.proposed_text === "value"
  end
end
