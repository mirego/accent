defmodule Accent.RoleAbilities do
  require Logger

  alias Accent.MachineTranslations

  @owner_role "owner"
  @admin_role "admin"
  @bot_role "bot"
  @developer_role "developer"
  @reviewer_role "reviewer"

  @read_actions ~w(
    lint
    format
    index_permissions
    index_versions
    export_version
    index_translations
    index_comments
    show_comment
    show_project
    index_collaborators
    show_translation
    index_project_activities
    index_related_translations
    index_revisions
    show_revision
    index_documents
    show_document
    show_activity
    index_translation_activities
    index_translation_comments_subscriptions
  )a

  @write_actions ~w(
    create_comment
    delete_comment
    update_comment
    correct_all_revision
    uncorrect_all_revision
    correct_translation
    uncorrect_translation
    update_translation
    create_translation_comments_subscription
    delete_translation_comments_subscription
  )a

  @any_actions @read_actions ++ @write_actions

  @bot_actions ~w(
    peek_sync
    peek_merge
    merge
    sync
    hook_update
  )a ++ @read_actions

  @developer_actions ~w(
    peek_sync
    peek_merge
    merge
    sync
    delete_document
    update_document
    list_project_api_tokens
    create_project_api_token
    revoke_project_api_token
    index_project_integrations
    create_project_integration
    update_project_integration
    delete_project_integration
    create_version
    update_version
  )a ++ @any_actions

  @admin_actions ~w(
    create_slave
    delete_slave
    promote_slave
    update_slave
    update_project
    delete_collaborator
    create_collaborator
    update_collaborator
    rollback
    lock_project_file_operations
    delete_project
  )a ++ @developer_actions

  @configurable_actions ~w(machine_translations_translate_document machine_translations_translate_file machine_translations_translate_text)a

  def actions_for(:all), do: add_configurable_actions(@admin_actions, @owner_role)
  def actions_for({:custom, permissions}), do: permissions
  def actions_for(@owner_role), do: add_configurable_actions(@admin_actions, @owner_role)
  def actions_for(@admin_role), do: add_configurable_actions(@admin_actions, @admin_role)
  def actions_for(@bot_role), do: add_configurable_actions(@bot_actions, @bot_role)
  def actions_for(@developer_role), do: add_configurable_actions(@developer_actions, @developer_role)
  def actions_for(@reviewer_role), do: add_configurable_actions(@any_actions, @reviewer_role)

  def add_configurable_actions(actions, role) do
    Enum.reduce(@configurable_actions, actions, fn action, actions ->
      if can?(role, action), do: [action | actions], else: actions
    end)
  end

  def can?(role, :machine_translations_translate_document) when role in [@owner_role, @admin_role, @developer_role] do
    MachineTranslations.translate_list_enabled?()
  end

  def can?(_role, :machine_translations_translate_document), do: false

  def can?(role, :machine_translations_translate_file) when role in [@owner_role, @admin_role, @developer_role] do
    MachineTranslations.translate_list_enabled?()
  end

  def can?(_role, :machine_translations_translate_file), do: false

  def can?(role, :machine_translations_translate_text) when role in [@owner_role, @admin_role, @developer_role] do
    MachineTranslations.translate_text_enabled?()
  end

  def can?(_role, :machine_translations_translate_text), do: false

  # Define abilities function at compile time to remove list lookup at runtime
  def can?(@owner_role, _action), do: true

  def can?({:custom, permissions}, action) do
    to_string(action) in permissions
  end

  for action <- @admin_actions do
    def can?(@admin_role, unquote(action)), do: true
  end

  for action <- @bot_actions do
    def can?(@bot_role, unquote(action)), do: true
  end

  for action <- @developer_actions do
    def can?(@developer_role, unquote(action)), do: true
  end

  for action <- @any_actions do
    def can?(@reviewer_role, unquote(action)), do: true
  end

  # Fallback if no permission has been found for the user on the project
  def can?(nil, _action), do: false

  def can?(role, action) do
    Logger.warn("Unauthorized action: #{action} for #{role}")
    false
  end
end
