defmodule Accent.Router do
  use Phoenix.Router
  use Sentry.Phoenix.Endpoint

  pipeline :graphql do
    plug(Accent.Plugs.AssignCurrentUser)
    plug(Accent.Plugs.SentryUserContext)
    plug(Accent.Plugs.BotParamsInjector)
    plug(Accent.Plugs.GraphQLContext)
    plug(Accent.Plugs.GraphQLOperationNameLogger)
  end

  scope "/graphiql" do
    pipe_through(:graphql)

    forward("/", Absinthe.Plug.GraphiQL, schema: Accent.GraphQL.Schema)
  end

  scope "/graphql" do
    pipe_through(:graphql)

    forward("/", Absinthe.Plug, schema: Accent.GraphQL.Schema, pipeline: {Accent.GraphQL.Schema, :absinthe_pipeline})
  end

  pipeline :authenticate do
    plug(Accent.Plugs.AssignCurrentUser)
    plug(Accent.Plugs.SentryUserContext)
    plug(Accent.Plugs.BotParamsInjector)
  end

  pipeline :browser do
    plug :accepts, ~w(json html)
    plug :fetch_session
    plug(:protect_from_forgery)
    plug :put_secure_browser_headers, %{"x-frame-options" => ""}
  end

  pipeline :metrics do
    plug :metrics_auth
  end

  defp metrics_auth(%{query_params: %{"share" => share}} = conn, _opts) when is_binary(share), do: conn

  defp metrics_auth(conn, _opts) do
    if System.get_env("METRICS_BASIC_AUTH") do
      [username, password] = String.split(System.fetch_env!("METRICS_BASIC_AUTH"), ":", parts: 2)
      Plug.BasicAuth.basic_auth(conn, username: username, password: password)
    else
      conn
      |> send_resp(:not_found, "Not found")
      |> halt()
    end
  end

  get("/metrics-public", TelemetryUI.Web.Share, [])

  scope "/" do
    pipe_through(:metrics)
    get("/metrics", TelemetryUI.Web, [], assigns: %{telemetry_ui_allowed: true})
  end

  scope "/", Accent do
    pipe_through(:authenticate)

    post("/format", FormatController, :format, as: :format)
    post("/lint", LintController, :lint, as: :lint)
    post("/sync", SyncController, [])
    post("/sync/peek", PeekController, :sync, as: :peek_sync)
    post("/add-translations", MergeController, [])
    post("/add-translations/peek", PeekController, :merge, as: :peek_add_translations)
    post("/merge", MergeController, [])
    post("/merge/peek", PeekController, :merge, as: :peek_merge)
    post("/machine-translations/translate-file", MachineTranslationsController, :translate_file, as: :translate_file)

    post("/machine-translations/translate-document", MachineTranslationsController, :translate_document,
      as: :translate_document
    )

    # File export
    get("/export", ExportController, [])
    get("/jipt-export", ExportJIPTController, [])
  end

  scope "/", Accent do
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
    get("/app/*path", WebAppController, [])
  end
end
