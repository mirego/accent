defmodule Accent.IntegrationManager.Execute.AzureStorageContainer do
  @moduledoc false

  alias Accent.Document
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Scopes.Document, as: DocumentScope
  alias Accent.Scopes.Revision, as: RevisionScope
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.Scopes.Version, as: VersionScope
  alias Accent.Translation
  alias Accent.Version

  def upload_translations(integration, params) do
    project = Repo.one!(Ecto.assoc(integration, :project))
    version = fetch_version(project, params)
    documents = fetch_documents(project)
    revisions = fetch_revisions(project)
    master_revision = Repo.preload(Repo.one!(RevisionScope.master(Ecto.assoc(project, :revisions))), :language)

    uploads =
      Enum.flat_map(documents, fn document ->
        Enum.flat_map(revisions, fn revision ->
          translations = fetch_translations(document, revision, version)

          if Enum.any?(translations) do
            render_options = %{
              translations: translations,
              master_language: Revision.language(master_revision),
              language: Revision.language(revision),
              document: document
            }

            %{render: render} = Accent.TranslationsRenderer.render_translations(render_options)
            [%{document: %{document | render: render}, language: Accent.Revision.language(revision)}]
          else
            []
          end
        end)
      end)

    for upload <- uploads do
      file = Path.join([System.tmp_dir(), Accent.Utils.SecureRandom.urlsafe_base64(16)])
      :ok = File.write(file, upload.document.render)

      uri = URI.parse(integration.data.azure_storage_container_sas)
      extension = Accent.DocumentFormat.extension_by_format(upload.document.format)

      path =
        Path.join([
          uri.path,
          (version && version.tag) || "latest",
          upload.language.slug,
          upload.document.path <> "." <> extension
        ])

      HTTPoison.put(URI.to_string(%{uri | path: path}), {:file, file}, [{"x-ms-blob-type", "BlockBlob"}])
    end

    :ok
  end

  defp fetch_version(project, %{target_version: :specific, tag: tag}) do
    Version
    |> VersionScope.from_project(project.id)
    |> VersionScope.from_tag(tag)
    |> Repo.one()
  end

  defp fetch_version(_, _) do
    nil
  end

  defp fetch_documents(project) do
    Document
    |> DocumentScope.from_project(project.id)
    |> Repo.all()
  end

  defp fetch_revisions(project) do
    Revision
    |> RevisionScope.from_project(project.id)
    |> Repo.all()
    |> Repo.preload(:language)
  end

  defp fetch_translations(document, revision, version) do
    Translation
    |> TranslationScope.active()
    |> TranslationScope.from_document(document.id)
    |> TranslationScope.from_revision(revision.id)
    |> TranslationScope.from_version(version && version.id)
    |> Repo.all()
  end
end
