defmodule Accent.RoleAbilities do
  @moduledoc false
  require Logger

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
    index_prompts
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
    save_project_machine_translations_config
    delete_project_machine_translations_config
    save_project_prompt_config
    delete_project_prompt_config
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

  @actions_with_target ~w(machine_translations_translate use_prompt_improve_text)a

  def actions_for(role, target)

  def actions_for(:all, target), do: add_actions_with_target(@admin_actions, @owner_role, target)
  def actions_for({:custom, permissions}, _target), do: permissions
  def actions_for(@owner_role, target), do: add_actions_with_target(@admin_actions, @owner_role, target)
  def actions_for(@admin_role, target), do: add_actions_with_target(@admin_actions, @admin_role, target)
  def actions_for(@bot_role, target), do: add_actions_with_target(@bot_actions, @bot_role, target)
  def actions_for(@developer_role, target), do: add_actions_with_target(@developer_actions, @developer_role, target)
  def actions_for(@reviewer_role, target), do: add_actions_with_target(@any_actions, @reviewer_role, target)

  defp add_actions_with_target(actions, role, target) do
    Enum.reduce(@actions_with_target, actions, fn action, actions ->
      if can?(role, action, target), do: [action | actions], else: actions
    end)
  end

  def can?(role, action, target \\ nil)

  def can?(_role, :machine_translations_translate, nil), do: false
  def can?(_role, :use_prompt_improve_text, nil), do: false

  def can?(_role, :machine_translations_translate, project) do
    Accent.MachineTranslations.enabled?(project.machine_translations_config)
  end

  def can?(_role, :use_prompt_improve_text, project) do
    Accent.Prompts.enabled?(project.prompt_config)
  end

  # Define abilities function at compile time to remove list lookup at runtime
  def can?(@owner_role, _action, _), do: true

  def can?({:custom, permissions}, action, _) do
    to_string(action) in permissions
  end

  for action <- @admin_actions do
    def can?(@admin_role, unquote(action), _), do: true
  end

  for action <- @bot_actions do
    def can?(@bot_role, unquote(action), _), do: true
  end

  for action <- @developer_actions do
    def can?(@developer_role, unquote(action), _), do: true
  end

  for action <- @any_actions do
    def can?(@reviewer_role, unquote(action), _), do: true
  end

  # Fallback if no permission has been found for the user on the project
  def can?(_role, _action, _), do: false
end
