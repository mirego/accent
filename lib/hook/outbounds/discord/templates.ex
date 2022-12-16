defmodule Hook.Outbounds.Discord.Templates do
  require EEx

  @sync_template """
  **<%= @user %>** just synced a file: *<%= @document_path %>*

  **Stats:**<%= for %{"action" => action, "count" => count} <- @stats do %>
  <%= Phoenix.Naming.humanize(action) %>: *<%= count %>*<% end %>
  """
  @new_conflicts_template """
  **<%= @user %>** just added *<%= @new_conflicts_count %> strings* to review.
  The project is currently **<%= @reviewed_count / @translations_count %>** reviewed (<%= @reviewed_count %>/<%= @translations_count %>)
  """
  @complete_review_template """
  **<%= @user %>** just finished reviewing all strings!
  The project currently has <%= @translations_count %> reviewed translations.
  """

  EEx.function_from_string(:def, :sync, @sync_template, [:assigns], trim: true)
  EEx.function_from_string(:def, :new_conflicts, @new_conflicts_template, [:assigns], trim: true)
  EEx.function_from_string(:def, :complete_review, @complete_review_template, [:assigns], trim: true)
end
