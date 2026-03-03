defmodule Accent.IntegrationManager.Execute.AWSS3 do
  @moduledoc false

  alias Accent.Hook
  alias Accent.IntegrationManager.Execute.UploadDocuments

  def upload_translations(integration, user, params) do
    {uploads, version_tag, version} = UploadDocuments.all(integration, params)

    # To support bucket with '.' in the name, we need to use the region subdomain.
    # The us-east-1 subdomain is not s3-us-east-1. It's s3 only.
    base_url =
      case integration.data.aws_s3_region do
        "us-east-1" -> "https://s3.amazonaws.com/#{integration.data.aws_s3_bucket}"
        region -> "https://s3-#{region}.amazonaws.com/#{integration.data.aws_s3_bucket}"
      end

    url =
      Path.join([
        base_url,
        integration.data.aws_s3_path_prefix
      ])

    uri = URI.parse(url)

    upload_results =
      for upload <- uploads do
        {url, document_name} = UploadDocuments.url(upload, uri, version_tag)

        headers =
          :aws_signature.sign_v4(
            integration.data.aws_s3_access_key_id,
            integration.data.aws_s3_secret_access_key,
            integration.data.aws_s3_region,
            "s3",
            :calendar.universal_time(),
            "put",
            url,
            [
              {"host", uri.authority},
              {"x-amz-acl", "public-read"},
              {"x-amz-tagging",
               "ACCENT_VERSION=#{Application.get_env(:accent, :version)}&USER_ID=#{user.id}&PROJECT_ID=#{integration.project_id}"}
            ],
            upload.render,
            uri_encode_path: false
          )

        response = HTTPoison.put(url, {:file, upload.file}, headers)

        %{name: document_name, url: url, response: serialize_response(response)}
      end

    document_urls = Enum.map(upload_results, &Map.take(&1, [:name, :url]))

    Hook.outbound(%Hook.Context{
      event: "integration_execute_aws_s3",
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
