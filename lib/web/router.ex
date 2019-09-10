defmodule Accent.Router do
  use Phoenix.Router
  use Sentry.Phoenix.Endpoint

  pipeline :graphql do
    plug(Accent.Plugs.AssignCurrentUser)
    plug(Accent.Plugs.SentryUserContext)
    plug(Accent.Plugs.BotParamsInjector)
    plug(Accent.Plugs.GraphQLContext)
  end

  scope "/graphiql" do
    pipe_through(:graphql)

    forward("/", Absinthe.Plug.GraphiQL, schema: Accent.GraphQL.Schema)
  end

  scope "/graphql" do
    pipe_through(:graphql)

    forward("/", Absinthe.Plug, schema: Accent.GraphQL.Schema)
  end

  pipeline :authenticate do
    plug(Accent.Plugs.AssignCurrentUser)
    plug(Accent.Plugs.SentryUserContext)
    plug(Accent.Plugs.BotParamsInjector)
  end

  pipeline :browser do
    plug :accepts, ~w(json html)
    plug :put_secure_browser_headers, %{"x-frame-options" => ""}
  end

  scope "/", Accent do
    pipe_through(:authenticate)

    post("/sync", SyncController, [])
    post("/sync/peek", PeekController, :sync, as: :peek_sync)
    post("/add-translations", MergeController, [])
    post("/add-translations/peek", PeekController, :merge, as: :peek_add_translations)
    post("/merge", MergeController, [])
    post("/merge/peek", PeekController, :merge, as: :peek_merge)

    # File export
    get("/export", ExportController, [])
    get("/jipt-export", ExportJIPTController, [])

    post("/hooks/github", Hook.GitHubController, [], as: :hooks_github)
  end

  scope "/", Accent do
    # Users
    # post("/auth", AuthenticationController, :create)

    get("/:id/percentage_reviewed_badge.svg", BadgeController, :percentage_reviewed_count)
    get("/:id/reviewed_badge.svg", BadgeController, :reviewed_count)
    get("/:id/conflicts_badge.svg", BadgeController, :conflicts_count)
    get("/:id/translations_badge.svg", BadgeController, :translations_count)
  end

  scope "/auth", Accent do
    pipe_through [:browser]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  scope "/", Accent do
    pipe_through(:browser)

    # Catch all route to serve the webapp from static dir
    get("/", WebAppController, [])
    get("/app*path", WebAppController, [])
  end
end
