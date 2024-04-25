defmodule Accent.IntegrationManager.Execute.AWSS3 do
  @moduledoc false

  alias Accent.Hook

  def upload_translations(integration, user, params) do
    {uploads, version_tag} = Accent.IntegrationManager.Execute.UploadDocuments.all(integration, params)

    # To support bucket with '.' in the name, we need to use the region subdomain.
    # The us-east-1 subdomain is not s3-us-east-1. It’s s3 only.
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

    document_urls =
      for upload <- uploads do
        {url, document_name} = Accent.IntegrationManager.Execute.UploadDocuments.url(upload, uri, version_tag)

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

        {:ok, %{status_code: 200}} = HTTPoison.put(url, {:file, upload.file}, headers)

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
