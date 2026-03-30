defmodule AccentTest.RoleAbilities do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Accent.RoleAbilities

  describe "update_translation_settings" do
    test "developer can update_translation_settings" do
      assert RoleAbilities.can?("developer", :update_translation_settings)
    end

    test "admin can update_translation_settings" do
      assert RoleAbilities.can?("admin", :update_translation_settings)
    end

    test "owner can update_translation_settings" do
      assert RoleAbilities.can?("owner", :update_translation_settings)
    end

    test "reviewer cannot update_translation_settings" do
      refute RoleAbilities.can?("reviewer", :update_translation_settings)
    end

    test "translator cannot update_translation_settings" do
      refute RoleAbilities.can?("translator", :update_translation_settings)
    end
  end
end
