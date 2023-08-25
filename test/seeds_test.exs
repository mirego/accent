defmodule AccentTest.Seeds do
  @moduledoc false
  use Accent.RepoCase, async: true

  test "upsert without fail" do
    assert Accent.Seeds.run(Accent.Repo) === :ok
  end
end
