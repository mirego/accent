defmodule Accent.Hook.Outbounds.Slack do
  @moduledoc false
  @behaviour Accent.Hook.Events

  use Oban.Worker, queue: :hook

  defmodule Templates do
    @moduledoc false
    import Accent.Hook.Outbounds.Helpers.StringTemplate

    deftemplate(:new_conflicts, """
    *<%= @user %>* just added _<%= @new_conflicts_count %> strings_ to review.
    The project is currently *<%= Float.round(@reviewed_count / @translations_count * 100, 2) %>%* reviewed (<%= @reviewed_count %>/<%= @translations_count %>)
    """)

    deftemplate(:sync, """
    *<%= @user %>* just synced a file: _<%= @document_path %>_

    *Stats:*<%= for %{"action" => action, "count" => count} <- @stats do %>
    <%= Phoenix.Naming.humanize(action) %>: _<%= count %>_<% end %>
    """)

    deftemplate(:complete_review, """
    *<%= @user %>* just finished reviewing all strings!
    The project currently has <%= @translations_count %> reviewed translations.
    """)

    deftemplate(:integration_execute_azure_storage_container, """
    *<%= @user %>* just uploaded all _<%= @version_tag %>_ files to Azure Container Storage.
    <%= for %{"name" => document_name, "url" => url} <- @document_urls do %>
    [<%= document_name %>](<%= url %>)
    <% end %>
    """)
  end

  @impl Accent.Hook.Events
  def registered_events do
    ~w(sync complete_review new_conflicts integration_execute_azure_storage_container)
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    context = Accent.Hook.Context.from_worker(args)

    Accent.Hook.Outbounds.Helpers.PostURL.perform("slack", context,
      http_body: &%{text: &1},
      templates: Templates
    )
  end
end
