defmodule AccentTest.IntegrationManager do
  @moduledoc false
  use Accent.RepoCase, async: true

  import Mock

  alias Accent.Document
  alias Accent.Integration
  alias Accent.IntegrationManager
  alias Accent.Language
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.User
  alias Accent.Version

  describe "execute" do
    setup do
      project = Repo.insert!(%Project{main_color: "red", name: "com"})
      user = Repo.insert!(%User{email: "test@test.com"})
      language = Repo.insert!(%Language{slug: "fr-custom", name: "Fr"})
      revision = Repo.insert!(%Revision{project: project, language: language})
      document = Repo.insert!(%Document{project: project, path: "foo", format: "gettext"})

      {:ok, [project: project, user: user, language: language, revision: revision, document: document]}
    end

    test "azure storage container with version", %{
      user: user,
      revision: revision,
      document: document,
      project: project
    } do
      version = Repo.insert!(%Version{project: project, tag: "1.2.45", name: "vNext", user: user})

      Repo.insert!(%Translation{
        revision: revision,
        document: document,
        key: "key",
        corrected_text: "value latest"
      })

      Repo.insert!(%Translation{
        revision: revision,
        version: version,
        document: document,
        key: "key",
        corrected_text: "value v1.2.45"
      })

      integration =
        Repo.insert!(%Integration{
          project: project,
          user: user,
          service: "azure_storage_container",
          data: %{azure_storage_container_sas: "http://azure.blob.test/container?sas=1234"}
        })

      with_mock HTTPoison,
        put: fn url, {:file, file}, headers ->
          content = File.read!(file)

          assert content === """
                 msgid "key"
                 msgstr "value v1.2.45"
                 """

          assert String.ends_with?(url, "1.2.45/fr-custom/foo.po?sas=1234")
          assert headers === [{"x-ms-blob-type", "BlockBlob"}]
          {:ok, nil}
        end do
        IntegrationManager.execute(integration, user, %{
          azure_storage_container: %{target_version: :specific, tag: "1.2.45"}
        })
      end

      updated_integration = Repo.reload!(integration)

      assert updated_integration.last_executed_at
      assert updated_integration.last_executed_by_user_id === user.id
    end

    test "azure storage container latest version", %{
      user: user,
      revision: revision,
      document: document,
      project: project
    } do
      Repo.insert!(%Translation{revision: revision, document: document, key: "key", corrected_text: "value"})

      integration =
        Repo.insert!(%Integration{
          project: project,
          user: user,
          service: "azure_storage_container",
          data: %{azure_storage_container_sas: "http://azure.blob.test/container?sas=1234"}
        })

      with_mock HTTPoison,
        put: fn url, body, headers ->
          assert match?({:file, _}, body)
          assert String.ends_with?(url, "latest/fr-custom/foo.po?sas=1234")
          assert headers === [{"x-ms-blob-type", "BlockBlob"}]
          {:ok, nil}
        end do
        IntegrationManager.execute(integration, user, %{azure_storage_container: %{target_version: :latest}})
      end

      updated_integration = Repo.reload!(integration)

      assert updated_integration.last_executed_at
      assert updated_integration.last_executed_by_user_id === user.id
    end
  end
end
