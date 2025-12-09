defmodule Accent.IntegrationManager.Execute.UploadDocuments do
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

  def url(upload, uri, version_tag) do
    extension = Accent.DocumentFormat.extension_by_format(upload.document.format)
    document_name = upload.document.path <> "." <> extension

    path =
      Path.join([
        uri.path || "/",
        version_tag,
        upload.language.slug,
        document_name
      ])

    {URI.to_string(%{uri | path: path}), document_name}
  end

  def all(integration, params) do
    project = Repo.one!(Ecto.assoc(integration, :project))
    version = fetch_version(project, params)
    documents = fetch_documents(project)
    revisions = fetch_revisions(project)

    master_revision =
      Repo.preload(Repo.one!(RevisionScope.master(Ecto.assoc(project, :revisions))), :language)

    version_tag = (version && version.tag) || "latest"

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
            file = Path.join([System.tmp_dir(), Accent.Utils.SecureRandom.urlsafe_base64(16)])
            :ok = File.write(file, render)

            [
              %{
                file: file,
                render: render,
                document: document,
                language: Revision.language(revision)
              }
            ]
          else
            []
          end
        end)
      end)

    {uploads, version_tag}
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
