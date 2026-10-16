[
  layers: [
    app: [
      "Accent",
      "Accent.ReleaseTasks",
      "Accent.Seeds",
      "Accent.Seeds.*",
      "Accent.TelemetryUI",
      "Accent.TelemetryUI.*"
    ],
    web: [
      "Accent.Endpoint",
      "Accent.Router",
      "Accent.*Controller",
      "Accent.BadgeView",
      "Accent.ErrorView",
      "Accent.LintView",
      "Accent.PeekView",
      "Accent.WebappView",
      "Accent.Plugs.Assign*",
      "Accent.Plugs.BotParamsInjector",
      "Accent.Plugs.EnsureUnlockedFileOperations",
      "Accent.Plugs.GraphQLOperationNameLogger",
      "Accent.Plugs.MovementContextParser",
      "Accent.Plugs.SentryUserContext",
      "Accent.Plugs.Session"
    ],
    graphql: ["Accent.GraphQL.*", "Accent.Plugs.GraphQLContext"],
    movement: ["Movement", "Movement.*"],
    domain: [
      "Accent.APITokenManager",
      "Accent.BadgeGenerator",
      "Accent.BadgeGenerator.*",
      "Accent.CollaboratorCreator",
      "Accent.CollaboratorUpdater",
      "Accent.DocumentManager",
      "Accent.IntegrationManager",
      "Accent.IntegrationManager.*",
      "Accent.MachineTranslationsConfigManager",
      "Accent.OperationBatcher",
      "Accent.ProjectCreator",
      "Accent.ProjectDeleter",
      "Accent.ProjectUpdater",
      "Accent.PromptConfigManager",
      "Accent.PromptManager",
      "Accent.RevisionManager",
      "Accent.Revisions.*",
      "Accent.TranslationsRenderer",
      "Accent.VersionFinder"
    ],
    lint: ["Accent.Lint", "Accent.Lint.*"],
    auth: [
      "Accent.AccessTokenUsageWriter",
      "Accent.Auth.*",
      "Accent.EmailAbilities",
      "Accent.RoleAbilities",
      "Accent.UserAuthFetcher",
      "Accent.UserRemote.*",
      "Canada.Can.*"
    ],
    hook: ["Accent.Hook", "Accent.Hook.*"],
    mailer: [
      "Accent.Mailer",
      "Accent.BaseEmail",
      "Accent.CreateCommentEmail",
      "Accent.ProjectInviteEmail",
      "Accent.EmailView",
      "Accent.EmailLayoutView",
      "Accent.EmailViewConfigHelper",
      "Accent.EmailViewStyleHelper"
    ],
    providers: ["Accent.MachineTranslations", "Accent.MachineTranslations.*", "Accent.Prompts", "Accent.Prompts.*"],
    scopes: "Accent.Scopes.*",
    schemas: [
      "Accent.Schema",
      "Accent.AccessToken",
      "Accent.AuthProvider",
      "Accent.Collaborator",
      "Accent.Comment",
      "Accent.Document",
      "Accent.DocumentFormat",
      "Accent.DocumentFormat.*",
      "Accent.Integration",
      "Accent.IntegrationExecution",
      "Accent.Language",
      "Accent.Operation",
      "Accent.PreviousTranslation",
      "Accent.Project",
      "Accent.Project.*",
      "Accent.ProjectLintEntry",
      "Accent.Prompt",
      "Accent.Revision",
      "Accent.Role",
      "Accent.Translation",
      "Accent.TranslationCommentsSubscription",
      "Accent.TranslationLint",
      "Accent.User",
      "Accent.Version"
    ],
    langue: ["Langue", "Langue.*"],
    infra: ["Accent.Config", "Accent.Repo", "Accent.Sentry", "Accent.Vault"],
    utils: ["Accent.HTTPClient", "Accent.PrettyFloat", "Accent.SecureRandom", "Accent.Utils.*", "Accessible"],
    test_support: ["Accent.RepoCase", "Accent.ConnCase", "Accent.Factory", "Accent.Factory.*"]
  ],
  deps: [
    mode: :allowlist,
    allowed: [
      app: [
        :web,
        :graphql,
        :movement,
        :domain,
        :lint,
        :auth,
        :hook,
        :mailer,
        :providers,
        :scopes,
        :schemas,
        :langue,
        :infra,
        :utils
      ],
      web: [
        :graphql,
        :movement,
        :domain,
        :lint,
        :auth,
        :hook,
        :providers,
        :scopes,
        :schemas,
        :langue,
        :infra,
        :utils
      ],
      graphql: [
        :movement,
        :domain,
        :lint,
        :auth,
        :hook,
        :providers,
        :scopes,
        :schemas,
        :langue,
        :infra,
        :utils
      ],
      movement: [:domain, :hook, :providers, :scopes, :schemas, :langue, :infra, :utils],
      domain: [:auth, :hook, :providers, :scopes, :schemas, :langue, :infra, :utils],
      lint: [:schemas, :langue, :infra, :utils],
      auth: [:providers, :scopes, :schemas, :infra, :utils],
      hook: [:mailer, :scopes, :schemas, :infra, :utils],
      mailer: [:schemas, :infra],
      providers: [:schemas, :langue, :infra, :utils],
      scopes: [:schemas],
      schemas: [:langue, :infra, :utils],
      langue: [:utils],
      infra: [:utils],
      utils: [],
      test_support: [
        :app,
        :web,
        :graphql,
        :movement,
        :domain,
        :lint,
        :auth,
        :hook,
        :mailer,
        :providers,
        :scopes,
        :schemas,
        :langue,
        :infra,
        :utils
      ]
    ]
  ],
  calls: [
    forbidden: [
      {"Accent.Scopes.*", ["Accent.Repo.*"]},
      {["Accent.*", "Movement.*", "Langue.*"], ["IO.puts", "IO.inspect", "Kernel.dbg"], except: ["Accent.ReleaseTasks"]}
    ]
  ],
  boundaries: [
    internal: [
      "Movement.Migration",
      "Movement.Migration.*",
      "Movement.Migrator",
      "Movement.Persisters.OperationsUpdateAllDynamic"
    ],
    internal_callers: [
      {"Movement.Migration", ["Movement.*"]},
      {"Movement.Migration.*", ["Movement.*"]},
      {"Movement.Migrator", ["Movement.*"]},
      {"Movement.Persisters.OperationsUpdateAllDynamic", ["Movement.*"]}
    ]
  ],
  checks: [
    source_paths: ["lib", "test/support"],
    layer_coverage: [
      require_all_modules: true,
      forbid_multiple_matches: true
    ]
  ],
  smells: [
    fixed_shape_map: [
      ignore: [paths: ["lib/accent/scopes/project.ex", "lib/accent/scopes/translations_count.ex"]]
    ],
    behaviour_candidate: [
      ignore: [modules: ["Accent.Lint.Checks.*", "Accent.Hook.Events.*"]]
    ]
  ],
  tests: [
    hints: [
      {"lib/langue/**", ["test/langue"]},
      {"lib/movement/**", ["test/movement"]},
      {"lib/lint/**", ["test/lint"]},
      {"lib/hook/**", ["test/hook"]},
      {"lib/graphql/**", ["test/graphql"]},
      {"lib/web/emails/**", ["test/emails"]},
      {"lib/web/plugs/**", ["test/plugs"]},
      {"lib/web/**", ["test/web"]},
      {"lib/accent/auth/**", ["test/auth", "test/accent/auth"]},
      {"lib/accent/scopes/**", ["test/scopes"]},
      {"lib/accent/schemas/**", ["test/schemas"]},
      {"lib/machine_translations/**", ["test/machine_translations"]},
      {"lib/accent/**", ["test/services"]}
    ]
  ]
]
