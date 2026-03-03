defmodule Accent.IntegrationManager.Execute.AzureStorageContainer do
  @moduledoc false

  alias Accent.Hook
  alias Accent.IntegrationManager.Execute.UploadDocuments

  def upload_translations(integration, user, params) do
    {uploads, version_tag, version} = UploadDocuments.all(integration, params)

    uri = URI.parse(integration.data.azure_storage_container_sas)

    upload_results =
      for upload <- uploads do
        {url, document_name} = UploadDocuments.url(upload, uri, version_tag)
        response = HTTPoison.put(url, {:file, upload.file}, [{"x-ms-blob-type", "BlockBlob"}])

        %{name: document_name, url: url, response: serialize_response(response)}
      end

    document_urls = Enum.map(upload_results, &Map.take(&1, [:name, :url]))

    Hook.outbound(%Hook.Context{
      event: "integration_execute_azure_storage_container",
      project_id: integration.project_id,
      user_id: user.id,
      payload: %{
        version_tag: version_tag,
        document_urls: document_urls
      }
    })

    {:ok,
     %{
       version_id: version && version.id,
       document_urls: document_urls,
       uploads: upload_results,
       version_tag: version_tag
     }}
  end

  defp serialize_response({:ok, %{status_code: status_code, body: body}}), do: %{status_code: status_code, body: body}
  defp serialize_response({:error, %{reason: reason}}), do: %{error: inspect(reason)}
  defp serialize_response(_), do: nil
end
