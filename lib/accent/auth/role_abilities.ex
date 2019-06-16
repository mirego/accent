defmodule Accent.RoleAbilities do
  @owner_role "owner"
  @admin_role "admin"
  @bot_role "bot"
  @developer_role "developer"
  @reviewer_role "reviewer"

  @any_actions ~w(
    index_permissions
    index_versions
    create_version
    update_version
    export_version
    index_translations
    index_comments
    create_comment
    show_comment
    correct_all_revision
    uncorrect_all_revision
    show_project
    index_collaborators
    correct_translation
    uncorrect_translation
    update_translation
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
    create_translation_comments_subscription
    delete_translation_comments_subscription
  )a

  @bot_actions ~w(
    peek_sync
    peek_merge
    merge
    sync
    hook_update
  )a ++ @any_actions

  @developer_actions ~w(
    peek_sync
    peek_merge
    merge
    sync
    delete_document
    update_document
    show_project_access_token
    index_project_integrations
    create_project_integration
    update_project_integration
    delete_project_integration
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

  def actions_for(@owner_role), do: @admin_actions
  def actions_for(@admin_role), do: @admin_actions
  def actions_for(@bot_role), do: @bot_actions
  def actions_for(@developer_role), do: @developer_actions
  def actions_for(@reviewer_role), do: @any_actions

  # Define abilities function at compile time to remove list lookup at runtime
  def can?(@owner_role, _action), do: true

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
  def can?(_role, _action), do: false
end
