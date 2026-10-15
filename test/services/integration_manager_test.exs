defmodule AccentTest.IntegrationManager do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Document
  alias Accent.Integration
  alias Accent.IntegrationExecution
  alias Accent.IntegrationManager
  alias Accent.Language
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Accent.User
  alias Accent.HTTPClient
  alias Accent.Version
  alias Plug.Conn

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

      Req.Test.stub(HTTPClient, fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)

        assert body === """
               msgid "key"
               msgstr "value v1.2.45"
               """

        assert conn.method === "PUT"
        assert String.ends_with?("#{conn.request_path}?#{conn.query_string}", "1.2.45/fr-custom/foo.po?sas=1234")
        assert Conn.get_req_header(conn, "x-ms-blob-type") === ["BlockBlob"]
        Conn.send_resp(conn, 201, "")
      end)

      IntegrationManager.execute(integration, user, %{
        azure_storage_container: %{target_version: :specific, tag: "1.2.45"}
      })

      updated_integration = Repo.reload!(integration)
      [execution] = Repo.all(IntegrationExecution)

      assert updated_integration.last_integration_execution_id === execution.id
      assert execution.integration_id === integration.id
      assert execution.user_id === user.id
      assert execution.version_id === version.id
      assert execution.state === :success
      assert execution.data === %{"target_version" => "specific", "tag" => "1.2.45"}
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

      Req.Test.stub(HTTPClient, fn conn ->
        assert conn.method === "PUT"
        assert String.ends_with?("#{conn.request_path}?#{conn.query_string}", "latest/fr-custom/foo.po?sas=1234")
        assert Conn.get_req_header(conn, "x-ms-blob-type") === ["BlockBlob"]
        Conn.send_resp(conn, 201, "")
      end)

      IntegrationManager.execute(integration, user, %{azure_storage_container: %{target_version: :latest}})

      updated_integration = Repo.reload!(integration)
      [execution] = Repo.all(IntegrationExecution)

      assert updated_integration.last_integration_execution_id === execution.id
      assert execution.integration_id === integration.id
      assert execution.user_id === user.id
      assert execution.version_id === nil
      assert execution.state === :success
      assert execution.data === %{"target_version" => "latest"}
    end
  end
end
