defmodule AccentTest.EmailAbilities do
  use ExUnit.Case, async: false

  alias Accent.EmailAbilities

  test "match without restricted email" do
    permissions = EmailAbilities.actions_for("foo@example.com")

    assert :create_project in permissions
    assert :index_permissions in permissions
    assert :index_projects in permissions
  end

  test "match with restricted email" do
    Application.put_env(:accent, :restricted_domain, "example.com")
    permissions = EmailAbilities.actions_for("foo@example.com")

    assert :create_project in permissions
    assert :index_permissions in permissions
    assert :index_projects in permissions
  end

  test "don’t match with restricted email" do
    Application.put_env(:accent, :restricted_domain, "example.com")
    permissions = EmailAbilities.actions_for("foo@bar.com")

    assert :index_permissions in permissions
    assert :index_projects in permissions
  end
end
