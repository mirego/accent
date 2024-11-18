defmodule Accent.Hook.Outbounds.Discord do
  @moduledoc false
  @behaviour Accent.Hook.Events

  use Oban.Worker, queue: :hook

  defmodule Templates do
    @moduledoc false
    import Accent.Hook.Outbounds.Helpers.StringTemplate

    deftemplate(:new_conflicts, """
    **<%= @user %>** just added *<%= @new_conflicts_count %> strings* to review.
    The project is currently **<%= Float.round(@reviewed_count / @translations_count * 100, 2) %>%** reviewed (<%= @reviewed_count %>/<%= @translations_count %>)
    """)

    deftemplate(:sync, """
    **<%= @user %>** just synced a file: *<%= @document_path %>*

    **Stats:**<%= for %{"action" => action, "count" => count} <- @stats do %>
    <%= Phoenix.Naming.humanize(action) %>: *<%= count %>*<% end %>
    """)

    deftemplate(:complete_review, """
    **<%= @user %>** just finished reviewing all strings!
    The project currently has <%= @translations_count %> reviewed translations.
    """)

    deftemplate(:integration_execute_azure_storage_container, """
    **<%= @user %>** just uploaded all *<%= @version_tag %>* files to Azure Container Storage.
    <%= for %{"name" => document_name, "url" => url} <- @document_urls do %>
    [<%= document_name %>](<%= url %>)
    <% end %>
    """)

    deftemplate(:integration_execute_aws_s3, """
    **<%= @user %>** just uploaded all *<%= @version_tag %>* files to AWS S3.
    <%= for %{"name" => document_name, "url" => url} <- @document_urls do %>
    [<%= document_name %>](<%= url %>)
    <% end %>
    """)
  end

  @impl Accent.Hook.Events
  def registered_events do
    ~w(sync complete_review new_conflicts integration_execute_azure_storage_container integration_execute_aws_s3)
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    context = Accent.Hook.Context.from_worker(args)

    Accent.Hook.Outbounds.Helpers.PostURL.perform("discord", context,
      http_body: &%{content: &1},
      templates: Templates
    )
  end
end
