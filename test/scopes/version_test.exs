defmodule AccentTest.Scopes.Version do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Project
  alias Accent.Repo
  alias Accent.Scopes.Version, as: VersionScope
  alias Accent.User
  alias Accent.Version

  doctest VersionScope

  defp assert_match_version(versions, version) do
    assert length(versions) === 1
    assert Enum.at(versions, 0).id === version.id
  end

  defp insert_version(tag, project, user) do
    Factory.insert(Version, name: "foo", tag: tag, project_id: project.id, user_id: user.id)
  end

  setup do
    user = Factory.insert(User, email: "test@test.com")
    project = Factory.insert(Project)

    {:ok, [user: user, project: project]}
  end

  test "filter no match tag", %{project: project, user: user} do
    insert_version("v1", project, user)

    versions = Repo.all(VersionScope.from_tag(Version, "== 1.1.0"))

    assert versions === []
  end

  test "filter exact tag", %{project: project, user: user} do
    version = insert_version("v1", project, user)

    versions = Repo.all(VersionScope.from_tag(Version, version.tag))

    assert_match_version(versions, version)
  end

  test "filter requirement tag", %{project: project, user: user} do
    version = insert_version("1.1.2", project, user)
    insert_version("1.2.2", project, user)

    versions = Repo.all(VersionScope.from_tag(Version, "== 1.1.2"))

    assert_match_version(versions, version)
  end

  test "filter exact requirement tag", %{project: project, user: user} do
    version = insert_version("== 1.1.2", project, user)
    insert_version("1.1.2", project, user)

    versions = Repo.all(VersionScope.from_tag(Version, "== 1.1.2"))

    assert_match_version(versions, version)
  end

  test "filter requirement tag with prefix", %{project: project, user: user} do
    version = insert_version("v1.1.2", project, user)
    insert_version("1.1.1", project, user)

    versions = Repo.all(VersionScope.from_tag(Version, "== 1.1.2"))

    assert_match_version(versions, version)
  end

  test "filter fish operator requirement tag", %{project: project, user: user} do
    version = insert_version("1.1.2", project, user)
    insert_version("1.1.0", project, user)

    versions = Repo.all(VersionScope.from_tag(Version, "~> 1.0"))

    assert_match_version(versions, version)
  end

  test "filter out invalid tag", %{project: project, user: user} do
    version = insert_version("1.1.2", project, user)
    insert_version("1.1.0", project, user)
    insert_version("foo", project, user)
    insert_version("bar", project, user)

    versions = Repo.all(VersionScope.from_tag(Version, "~> 1.0"))

    assert_match_version(versions, version)
  end
end
