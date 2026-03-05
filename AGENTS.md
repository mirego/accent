# Accent — Agent Guide

Self-hosted translation management platform.
Elixir 1.18 / OTP 27 · Phoenix · Ecto (PostgreSQL, UUID PKs) · Absinthe (GraphQL) · Oban (jobs)

## Verify

```bash
# Tests (requires .env.test.local with DATABASE_URL)
env $(cat .env.test.local | xargs) mix test
env $(cat .env.test.local | xargs) mix test path/to/test.exs:42

# All CI checks
env $(cat .env.test.local | xargs) mix test
mix format --check-formatted
mix credo --strict
mix compile --warnings-as-errors --force
mix dialyzer
```

## Architecture Map

```
lib/
├── accent/              # Core domain
│   ├── schemas/         # 22 Ecto schemas (Translation, Project, Revision, Operation, …)
│   └── scopes/          # Composable query filters (12 modules, one per schema)
├── graphql/
│   ├── schema.ex        # Absinthe root schema
│   ├── resolvers/       # Query/mutation handlers
│   └── types/           # GraphQL type definitions
├── web/                 # Phoenix controllers, plugs, router
├── movement/            # Translation operation pipeline
│   ├── context.ex       # Pipeline data carrier (entries, operations, assigns)
│   ├── builders/        # Generate operations from context (14 builders)
│   ├── persisters/      # Persist operations + trigger migrations
│   ├── migration/       # Apply changes to translations
│   └── mappers/         # Map data to operation structs
├── langue/              # File format parsing/serialization
│   └── formatter/       # 15 formats: json, gettext, xliff_1_2, strings, csv, …
├── hook/                # Event system (events/ + outbounds/)
├── lint/                # Translation quality checks (9 checks in lint/checks/)
├── machine_translations/# MT providers
└── prompts/             # AI prompt management
```

## Key Patterns — Where to Look

Don't memorize patterns; read the canonical files:

| Pattern            | Read this file                                         |
| ------------------ | ------------------------------------------------------ |
| Movement builder   | `lib/movement/builders/translation_update.ex`          |
| Movement persister | `lib/movement/persisters/base.ex`                      |
| Operation mapping  | `lib/movement/mappers/operation.ex`                    |
| Ecto scope         | `lib/accent/scopes/translation.ex`                     |
| GraphQL resolver   | `lib/graphql/resolvers/translation.ex`                 |
| GraphQL type       | `lib/graphql/types/translation.ex`                     |
| Langue formatter   | `lib/langue/formatter/json/` (simplest example)        |
| Lint check         | `lib/lint/checks/trailing_space.ex`                    |
| Hook event         | `lib/hook/events/`                                     |
| Test setup         | `test/support/repo_case.ex`, `test/support/factory.ex` |
| Auth roles         | `lib/accent/auth/role_abilities.ex`                    |
| Schema base        | `lib/accent/schemas/schema.ex`                         |

## Testing Conventions

- Case template: `use Accent.RepoCase, async: true`
- Factory: `Factory.insert(Schema, field: value)` — uses Factori, not ExMachina
- Oban assertions available via `use Oban.Testing` (included in RepoCase)
- Worker args helper: `to_worker_args/1` converts structs to worker-safe maps

## Golden Rules

1. **No comments in code.** Code is self-documenting. No inline comments in tests. Only comment truly non-obvious workarounds with external references.
2. **Format everything.** `mix format` — line length 120, Styler plugin, imports from `:ecto, :phoenix`.
3. **Credo strict.** `mix credo --strict` must pass. ModuleDoc check is disabled.
4. **Warnings are errors.** `mix compile --warnings-as-errors` in CI.
5. **UUID primary keys.** All schemas use `binary_id`. See `lib/accent/schemas/schema.ex`.
6. **Scopes for queries.** Never inline query filters in resolvers/controllers. Compose via `lib/accent/scopes/`.
7. **Movement pipeline for translation ops.** Builder → Persister → Migration. Never mutate translations outside this pipeline.
8. **Tests are async.** Always `async: true` unless there's a specific shared-state reason.
9. **No new dependencies without justification.** The stack is deliberate.
