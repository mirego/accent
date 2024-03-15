defmodule Accent.IntegrationManager.Execute.AzureStorageContainer do
  @moduledoc false

  alias Accent.Hook

  def upload_translations(integration, user, params) do
    {uploads, version_tag} = Accent.IntegrationManager.Execute.UploadDocuments.all(integration, params)

    uri = URI.parse(integration.data.azure_storage_container_sas)

    document_urls =
      for upload <- uploads do
        {url, document_name} = Accent.IntegrationManager.Execute.UploadDocuments.url(upload, uri, version_tag)
        HTTPoison.put(url, {:file, upload.file}, [{"x-ms-blob-type", "BlockBlob"}])

        %{name: document_name, url: url}
      end

    Hook.outbound(%Hook.Context{
      event: "integration_execute_azure_storage_container",
      project_id: integration.project_id,
      user_id: user.id,
      payload: %{
        version_tag: version_tag,
        document_urls: document_urls
      }
    })

    :ok
  end
end
