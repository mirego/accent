defmodule AccentTest.VersionFinder do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Project
  alias Accent.User
  alias Accent.Version
  alias Accent.VersionFinder

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

    found = VersionFinder.find_by_tag(project.id, "== 1.1.0")

    assert found === nil
  end

  test "filter exact tag", %{project: project, user: user} do
    version = insert_version("v1", project, user)

    found = VersionFinder.find_by_tag(project.id, version.tag)

    assert found.id === version.id
  end

  test "filter requirement tag", %{project: project, user: user} do
    version = insert_version("1.1.2", project, user)
    insert_version("1.2.2", project, user)

    found = VersionFinder.find_by_tag(project.id, "== 1.1.2")

    assert found.id === version.id
  end

  test "filter exact requirement tag", %{project: project, user: user} do
    version = insert_version("== 1.1.2", project, user)
    insert_version("1.1.2", project, user)

    found = VersionFinder.find_by_tag(project.id, "== 1.1.2")

    assert found.id === version.id
  end

  test "filter requirement tag with prefix", %{project: project, user: user} do
    version = insert_version("v1.1.2", project, user)
    insert_version("1.1.1", project, user)

    found = VersionFinder.find_by_tag(project.id, "== 1.1.2")

    assert found.id === version.id
  end

  test "filter fish operator requirement tag", %{project: project, user: user} do
    version = insert_version("1.1.2", project, user)
    insert_version("1.1.0", project, user)

    found = VersionFinder.find_by_tag(project.id, "~> 1.0")

    assert found.id === version.id
  end

  test "filter out invalid tag", %{project: project, user: user} do
    version = insert_version("1.1.2", project, user)
    insert_version("1.1.0", project, user)
    insert_version("foo", project, user)
    insert_version("bar", project, user)

    found = VersionFinder.find_by_tag(project.id, "~> 1.0")

    assert found.id === version.id
  end
end
