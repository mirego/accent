defmodule Hook.Outbounds.Slack.Templates do
  @moduledoc false
  require EEx

  @sync_template """
  *<%= @user %>* just synced a file: _<%= @document_path %>_

  *Stats:*<%= for %{"action" => action, "count" => count} <- @stats do %>
  <%= Phoenix.Naming.humanize(action) %>: _<%= count %>_<% end %>
  """
  @new_conflicts_template """
  *<%= @user %>* just added _<%= @new_conflicts_count %> strings_ to review.
  The project is currently *<%= Float.round(@reviewed_count / @translations_count * 100, 2) %>* reviewed (<%= @reviewed_count %>/<%= @translations_count %>)
  """
  @complete_review_template """
  *<%= @user %>* just finished reviewing all strings!
  The project currently has <%= @translations_count %> reviewed translations.
  """

  EEx.function_from_string(:def, :sync, @sync_template, [:assigns], trim: true)
  EEx.function_from_string(:def, :new_conflicts, @new_conflicts_template, [:assigns], trim: true)
  EEx.function_from_string(:def, :complete_review, @complete_review_template, [:assigns], trim: true)
end
