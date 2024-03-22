defmodule AccentTest.IntegrationManager do
  @moduledoc false
  use Accent.RepoCase, async: false

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
      project = Factory.insert(Project)
      user = Factory.insert(User)
      language = Factory.insert(Language, slug: "fr-custom")

      revision =
        Factory.insert(Revision,
          master: true,
          master_revision_id: nil,
          project_id: project.id,
          language_id: language.id
        )

      document = Factory.insert(Document, project_id: project.id, path: "foo", format: "gettext")

      {:ok, [project: project, user: user, language: language, revision: revision, document: document]}
    end

    test "azure storage container with version", %{
      user: user,
      revision: revision,
      document: document,
      project: project
    } do
      version = Factory.insert(Version, project_id: project.id, tag: "1.2.45", name: "vNext", user_id: user.id)

      Factory.insert(Translation,
        revision_id: revision.id,
        document_id: document.id,
        key: "key",
        corrected_text: "value latest"
      )

      Factory.insert(Translation,
        revision_id: revision.id,
        version_id: version.id,
        document_id: document.id,
        key: "key",
        corrected_text: "value v1.2.45"
      )

      integration =
        Factory.insert(Integration,
          project_id: project.id,
          user_id: user.id,
          service: "azure_storage_container",
          data: %{azure_storage_container_sas: "http://azure.blob.test/container?sas=1234"}
        )

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
      Factory.insert(Translation,
        revision_id: revision.id,
        document_id: document.id,
        key: "key",
        corrected_text: "value"
      )

      integration =
        Factory.insert(Integration,
          project_id: project.id,
          user_id: user.id,
          service: "azure_storage_container",
          data: %{azure_storage_container_sas: "http://azure.blob.test/container?sas=1234"}
        )

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
