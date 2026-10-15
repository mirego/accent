defmodule AccentTest.BadgeGenerator do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.BadgeGenerator
  alias Accent.Document
  alias Accent.Language
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Translation
  alias Plug.Conn

  defp stub_badge(expected_url) do
    Req.Test.expect(Accent.HTTPClient, fn conn ->
      assert "#{conn.scheme}://#{conn.host}#{conn.request_path}" === expected_url
      Conn.send_resp(conn, 200, "<svg></svg>")
    end)
  end

  setup do
    french_language = Factory.insert(Language)
    project = Factory.insert(Project, language_id: french_language.id)
    revision = Factory.insert(Revision, language_id: french_language.id, master: true, project_id: project.id)
    document = Factory.insert(Document, project_id: project.id, path: "test2", format: "json")

    {:ok, [project: Repo.preload(project, :revisions), revision: revision, document: document]}
  end

  test "percentage_reviewed error", %{project: project, revision: revision, document: document} do
    Factory.insert(Translation,
      revision_id: revision.id,
      key: "a",
      conflicted: true,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "b",
      conflicted: true,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "c",
      conflicted: false,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    stub_badge("https://img.shields.io/badge/accent-33.33%25-d84444.svg")

    {:ok, _} = BadgeGenerator.generate(project, :percentage_reviewed_count)
  end

  test "percentage_reviewed warning", %{project: project, revision: revision, document: document} do
    Factory.insert(Translation,
      revision_id: revision.id,
      key: "a",
      conflicted: true,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "b",
      conflicted: false,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "c",
      conflicted: false,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "d",
      conflicted: false,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    stub_badge("https://img.shields.io/badge/accent-75%25-e4b600.svg")

    {:ok, _} = BadgeGenerator.generate(project, :percentage_reviewed_count)
  end

  test "percentage_reviewed success", %{project: project, revision: revision, document: document} do
    Factory.insert(Translation,
      revision_id: revision.id,
      key: "a",
      conflicted: false,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "b",
      conflicted: false,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "c",
      conflicted: false,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "d",
      conflicted: false,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    stub_badge("https://img.shields.io/badge/accent-100%25-45c86f.svg")

    {:ok, _} = BadgeGenerator.generate(project, :percentage_reviewed_count)
  end

  test "translations_count", %{project: project, revision: revision, document: document} do
    Factory.insert(Translation,
      revision_id: revision.id,
      key: "a",
      conflicted: false,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "b",
      conflicted: false,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "c",
      conflicted: false,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "d",
      conflicted: false,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    stub_badge("https://img.shields.io/badge/accent-4%20strings-aaaaaa.svg")

    {:ok, _} = BadgeGenerator.generate(project, :translations_count)
  end

  test "conflicts_count", %{project: project, revision: revision, document: document} do
    Factory.insert(Translation,
      revision_id: revision.id,
      key: "c",
      conflicted: true,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "d",
      conflicted: true,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    stub_badge("https://img.shields.io/badge/accent-2%20conflicts-d84444.svg")

    {:ok, _} = BadgeGenerator.generate(project, :conflicts_count)
  end

  test "reviewed_count", %{project: project, revision: revision, document: document} do
    Factory.insert(Translation,
      revision_id: revision.id,
      key: "c",
      conflicted: false,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    Factory.insert(Translation,
      revision_id: revision.id,
      key: "d",
      conflicted: false,
      corrected_text: "initial",
      proposed_text: "initial",
      document_id: document.id
    )

    stub_badge("https://img.shields.io/badge/accent-2%20reviewed-aaaaaa.svg")

    {:ok, _} = BadgeGenerator.generate(project, :reviewed_count)
  end

  test "zero translations", %{project: project} do
    stub_badge("https://img.shields.io/badge/accent-0%25-d84444.svg")

    {:ok, _} = BadgeGenerator.generate(project, :percentage_reviewed_count)
  end
end
