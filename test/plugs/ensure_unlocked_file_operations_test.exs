defmodule AccentTest.Plugs.EnsureUnlockedFileOperations do
  use ExUnit.Case
  use Plug.Test

  alias Accent.Plugs.EnsureUnlockedFileOperations

  alias Accent.Project

  test "no halt conn" do
    updated_conn =
      :get
      |> conn("/foo")
      |> assign(:project, %Project{locked_file_operations: false})
      |> EnsureUnlockedFileOperations.call(EnsureUnlockedFileOperations.init([]))

    assert updated_conn.state == :unset
  end

  test "halt conn" do
    updated_conn =
      :get
      |> conn("/foo")
      |> assign(:project, %Project{locked_file_operations: true})
      |> EnsureUnlockedFileOperations.call(EnsureUnlockedFileOperations.init([]))

    assert updated_conn.state == :sent
    assert updated_conn.status == 403
    assert updated_conn.resp_body == "File operations are locked"
  end
end
