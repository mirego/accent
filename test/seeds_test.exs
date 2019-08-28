defmodule AccentTest.Seeds do
  use Accent.RepoCase, async: true

  test "upsert without fail" do
    assert Accent.Seeds.run(Accent.Repo) === :ok
  end
end
