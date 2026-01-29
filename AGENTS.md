# Accent API Development Guide

## Project Overview

Accent is a self-hosted translation management platform. The API is built with:

- **Elixir 1.18** / **Erlang/OTP 27**
- **Phoenix Framework** - Web layer
- **Ecto** - Database (PostgreSQL)
- **Absinthe** - GraphQL API
- **Oban** - Background jobs

## Running Tests

```bash
# Load environment and run all tests
env $(cat .env.test.local | xargs) mix test

# Run specific test file
env $(cat .env.test.local | xargs) mix test test/movement/builders/translation_update_test.exs

# Run with trace (verbose output)
env $(cat .env.test.local | xargs) mix test --trace

# Run specific test by line number
env $(cat .env.test.local | xargs) mix test test/path/to/test.exs:42
```

## Test Conventions

```elixir
# Use RepoCase for database tests
defmodule AccentTest.Movement.Builders.MyBuilder do
  use Accent.RepoCase, async: true

  alias Accent.Translation
  alias Movement.Context

  test "my test" do
    # Use Factory to create test data
    user = Factory.insert(User, email: "test@test.com")
    language = Factory.insert(Language)
    translation = Factory.insert(Translation, key: "hello", revision_id: revision.id)

    # Test your code
    assert result == expected
  end
end
```

## Formatting

```bash
# Check formatting (CI mode)
mix format --check-formatted

# Auto-format all Elixir files
mix format

# Format specific files
mix format lib/movement/builders/my_file.ex
```

Configuration (`.formatter.exs`):

- Line length: 120
- Uses Styler plugin
- Imports deps: `:ecto, :phoenix`

## Linting

```bash
# Run Credo (strict mode)
mix credo --strict

# Check specific file
mix credo lib/movement/builders/my_file.ex

# Compile with warnings as errors
mix compile --warnings-as-errors --force
```

Configuration (`.credo.exs`):

- Strict mode enabled
- ModuleDoc check disabled
- Max line length: 200

## Type Checking

```bash
# Run Dialyzer
mix dialyzer

# First run builds PLT cache (slow)
# Subsequent runs use cached PLT
```

## Full CI Check

```bash
# Run all checks (same as CI)
./priv/scripts/ci-check.sh

# Or via Makefile
make lint          # All linters
make type-check    # Dialyzer + TypeScript
```

## Common Patterns

### Movement System (Translation Operations)

The movement system handles translation sync/merge/update operations:

1. **Builder** - Generates operations from context
2. **Persister** - Persists operations and runs migrations
3. **Migrator** - Routes operations to migration modules
4. **Migration** - Applies changes to translations

```elixir
# Builder pattern
defmodule Movement.Builders.MyBuilder do
  @behaviour Movement.Builder

  def build(%Movement.Context{assigns: %{translation: translation}} = context) do
    operation = OperationMapper.map("my_action", translation, %{text: text})
    %{context | operations: context.operations ++ [operation]}
  end
end
```

### GraphQL Resolvers

```elixir
# Resolver pattern
defmodule Accent.GraphQL.Resolvers.MyResolver do
  def my_query(parent, args, %{context: context}) do
    # Access current user: context[:conn].assigns[:current_user]
    {:ok, result}
  end
end
```

### Ecto Queries with Scopes

```elixir
# Use scopes for reusable query filters
Translation
|> TranslationScope.from_project(project_id)
|> TranslationScope.from_revision(revision_id)
|> TranslationScope.active()
|> Repo.all()
```

## Key Files Reference

| Purpose            | Location                            |
| ------------------ | ----------------------------------- |
| GraphQL Schema     | `lib/graphql/schema.ex`             |
| Translation Schema | `lib/accent/schemas/translation.ex` |
| Project Schema     | `lib/accent/schemas/project.ex`     |
| Translation Scopes | `lib/accent/scopes/translation.ex`  |
| Movement Context   | `lib/movement/context.ex`           |
| Operation Mapper   | `lib/movement/mappers/operation.ex` |
| Test Factory       | `test/support/factory.ex`           |
| Repo Test Case     | `test/support/repo_case.ex`         |

## Environment Setup

Required for tests:

```bash
# .env.test.local should contain:
DATABASE_URL=postgres://user:pass@localhost/accent_test
```
