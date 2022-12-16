defmodule Movement.Persisters.ProjectStateChangeWorkerTest do
  use Accent.RepoCase
  use Oban.Testing, repo: Accent.Repo

  alias Movement.Persisters.ProjectStateChangeWorker, as: Worker

  alias Accent.{
    Document,
    Language,
    ProjectCreator,
    Repo,
    Translation,
    User
  }

  setup do
    user = Repo.insert!(%User{email: "test@test.com"})
    language = Repo.insert!(%Language{name: "English", slug: Ecto.UUID.generate()})
    {:ok, project} = ProjectCreator.create(params: %{main_color: "#f00", name: "My project", language_id: language.id}, user: user)
    revision = project |> Repo.preload(:revisions) |> Map.get(:revisions) |> hd()
    document = Repo.insert!(%Document{project_id: project.id, path: "test", format: "json"})

    {:ok, [revision: revision, document: document, project: project, user: user]}
  end

  test "noop", %{project: project} do
    args = %{
      "project_id" => project.id,
      "previous_project_state" => %{
        "project" => %{
          "translations_count" => 0,
          "reviewed_count" => 0,
          "conflicts_count" => 0
        }
      }
    }

    Worker.perform(%Oban.Job{args: args})

    refute_enqueued(worker: Accent.Hook.Outbounds.Mock)
  end

  test "new_conflicts", %{user: user, project: project, revision: revision, document: document} do
    %Translation{
      key: "a",
      proposed_text: "A",
      conflicted: true,
      corrected_text: "Test",
      revision_id: revision.id,
      document_id: document.id
    }
    |> Repo.insert!()

    args = %{
      "project_id" => project.id,
      "user_id" => user.id,
      "previous_project_state" => %{
        "project" => %{
          "translations_count" => 0,
          "reviewed_count" => 0,
          "conflicts_count" => 0
        }
      }
    }

    Worker.perform(%Oban.Job{args: args})

    assert_enqueued(
      worker: Accent.Hook.Outbounds.Mock,
      args: %{
        "event" => "new_conflicts",
        "payload" => %{
          "reviewed_count" => 0,
          "translations_count" => 1,
          "new_conflicts_count" => 1
        },
        "project_id" => project.id,
        "user_id" => user.id
      }
    )
  end

  test "complete_review", %{user: user, project: project, revision: revision, document: document} do
    %Translation{
      key: "a",
      proposed_text: "A",
      conflicted: false,
      corrected_text: "Test",
      revision_id: revision.id,
      document_id: document.id
    }
    |> Repo.insert!()

    args = %{
      "project_id" => project.id,
      "user_id" => user.id,
      "previous_project_state" => %{
        "project" => %{
          "translations_count" => 1,
          "reviewed_count" => 0,
          "conflicts_count" => 1
        }
      }
    }

    Worker.perform(%Oban.Job{args: args})

    assert_enqueued(
      worker: Accent.Hook.Outbounds.Mock,
      args: %{
        "event" => "complete_review",
        "payload" => %{
          "translations_count" => 1
        },
        "project_id" => project.id,
        "user_id" => user.id
      }
    )
  end
end
