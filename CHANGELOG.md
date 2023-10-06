# Changelog

## v1.19.0

Added: Spellchecker with https://languagetool.org/

We bundle a jar file and install Java runtime in docker to be able to use languagetool spellchecker locally and very fast.
This is the first version of the integration, we are still missing some important feature like "Ignore rules", "Custom project dictionary" or "Placeholder handling".

## v1.18.4

Updated: Dockerfile fixes

## v1.18.3 - Released on 2023-08-29

Fixed: Compilation issues with the route ueberauth controller.

## v1.18.2 - Released on 2023-08-29

Fixed: A redirect issue.

## v1.18.1 - Released on 2023-08-29

Fixed: An authentication request issue.

## v1.18.0 - Released on 2023-08-29

Fixed: Slack and GitLab login issues.
Fixed: Parsing of namePattern and added documentation in README.
Updated: Bumped CLI to version 0.14.0.

## v1.17.0 - Released on 2023-08-25

Reverted: A Docker action.
Fixed: A Discord webhook issue.
Added: MAILGUN_BASE_URI and documented missing environment variable.
Updated: Docker/build-push-action to version v4.
Updated: CLI README.md.

## v1.16.7 - Released on 2023-08-16

Fixed: Related translation with duplicate keys (one removed, one active).

## v1.16.6 - Released on 2023-08-07

Fixed: A Credo issue.

## v1.16.5 - Released on 2023-08-04

Removed: Debug code.

## v1.16.4 - Released on 2023-08-04

Updated: Dependencies.
Added: Sync lock version on project to prevent race condition on sync.
Added: Revision deleter in worker to use an infinite repo transaction timeout.
Fixed: Oban perform result for outbound email.
Used: @mirego’s fork for create-pull-request action in workflow.

## v1.16.3 - Released on 2023-05-24

Fixed: Lint on all versions instead of the current one.
Updated: Bumped CLI to version 0.13.3.
Fixed: Flags override issue.

## v1.16.2 - Released on 2023-05-02

Fixed: An issue with CLI configuration.
Please replace "Released on" with the actual release date of each version. Additionally, you can include more details if needed, such as specific bug numbers or contributors, to make the changelog more informative.

## v1.16.0

### 1. Enhancements

- AI assistant with OpenAI integration

## v1.15.0

### 1. Enhancements

- New UI :tada:

## v1.14.0

### 1. Enhancements

- Canonical host redirect
- Add API token management with granular permissions
- Add machine translations config with Google Translate and DeepL integration
- Add `ecto_psql_extras` to TelemetryUI
- Add auth0 uberauth provider

### 2. Bug fixes

- Fix invalid unicode file parsing
- Fix placeholder and url linting rule

## v1.12.0

### 1. Enhancements

- Support RTL languages in webapp
- Add versions support in sync/add translation in webapp and CLI
- Optimize SQL batch operations to use Ecto placeholders
- CLI has a warning if 2 files in the config have the exact same folder
- Add GitHub Actions instructions in CLI Readme

### 2. Bug fixes

- Documents list action links does not slide to the left to put the delete button uner the cursor
- Fix `accent format --order-by` option
- Fix large number of concurrent HTTP requests in CLI sync

## v1.9.0

### 1. Enhancements

- Colorful file preview with highlight.js
- Machine translations on document and review items

### 2. Bug fixes

- Large review list values does not crash the browser

### 3. Refactor

- Update Elixir/erlang and EmberJS to latest version

## v1.8.0

### 1. Enhancements

- Comment deletion
- Add export advanced filters
- Add merge options on add translation to correct translation in the same operation
- Add default null option on new slave

### 2. Bug fixes

- Fix Sentry setup

### 3. Refactor

- Update Elixir/erlang and EmberJS to latest version
- Conflicts page item delays rendering to handle large list of large values

## v1.6.0

### 1. Enhancements

- New review page that includes more context on translations
- Add recent projects section in projects listing
- Add Resx 2.0 format
- Add batch activity support for batch activity (sync, add translations)
- Add markdown conversation
- Add file comment UI on a translation page

### 2. Bug fixes

- Fix slow textarea and text input
- Fix large strings textarea that broke the UI

### 3. Refactor

- Add type-safe Gleam language to build linting rules
- Replae homemade gen_stage async jobs processor with Oban
- Upgrade to latest Elixir and latest EmberJS
- Use animated svg for skeleton UI instead of plain CSS
