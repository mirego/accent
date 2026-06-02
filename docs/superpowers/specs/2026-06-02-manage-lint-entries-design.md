# Manage Project Lint Entries — Design

## Goal

Expose `update`/`delete`/`create` GraphQL mutations to fully manage `Accent.ProjectLintEntry`, and add a modal UI on the project settings "Lint rules" list page to create, edit, and delete entries.

The create mutation and the read-only list view already exist (see `.opencode/plans/1780426264274-curious-engine.md`). This spec adds the missing mutations and the management UI.

## Confirmed decisions

- **type select**: lists all 4 enum values (`all`, `term`, `key`, `language_tool_rule_id`), defaulting to the entry's current value. `term`/`key` are the primary intended choices but existing entries with `all`/`language_tool_rule_id` must edit without forced change.
- **check_ids**: power-select multiple dropdown (`<AccSelect @multi={{true}}>`) over the fixed `lint_check` enum.
- **create gets optional `ignore` arg**: so the modal checkbox is respected on create; existing per-translation callers omit it (DB default `true`).
- **Add button + create mode**: the list page gets an "Add lint rule" button opening the modal blank.
- **Delete button** lives inside the modal (edit mode only), with a confirm dialog.

## Enum reference

- `lint_entry_type` (`lib/graphql/mutations/lint.ex`): `all`, `term`, `key`, `language_tool_rule_id`. GraphQL exposes UPPER_SNAKE (e.g. `LANGUAGE_TOOL_RULE_ID`).
- `lint_check` (`lib/graphql/types/lint.ex`): `spelling`, `leading_spaces`, `double_spaces`, `first_letter_case`, `apostrophe_as_single_quote`, `three_dots_ellipsis`, `same_trailing_character`, `trailing_space`, `placeholder_count`, `url_count`. `check_ids` is typed as `[ID!]` — values are these check strings.

---

## Backend (Elixir / Absinthe)

### 1. Schema changesets — `lib/accent/schemas/project_lint_entry.ex`

Add changesets (mirror `lib/accent/schemas/comment.ex` style):

```elixir
@cast_fields ~w(check_ids value type ignore project_id)a
@required_fields ~w(type project_id)a

def create_changeset(model, params) do
  model
  |> cast(params, @cast_fields)
  |> validate_required(@required_fields)
  |> assoc_constraint(:project)
end

def update_changeset(model, params) do
  model
  |> cast(params, ~w(check_ids value type ignore)a)
  |> validate_required(~w(type)a)
end
```

`use Accent.Schema` already imports `Ecto.Changeset`. `check_ids` defaults to `[]`, `ignore` to DB default `true` when not cast.

### 2. Context — `lib/lint/lint.ex`

Refactor create to use the changeset (so `ignore` is honored) and add update/delete:

```elixir
def create_lint_entry(args) do
  %ProjectLintEntry{}
  |> ProjectLintEntry.create_changeset(args)
  |> Repo.insert()
end

def update_lint_entry(lint_entry, args) do
  lint_entry
  |> ProjectLintEntry.update_changeset(args)
  |> Repo.update()
end

def delete_lint_entry(lint_entry) do
  Repo.delete(lint_entry)
end
```

`args` is a map with atom keys from Absinthe. `create_changeset`/`update_changeset` cast string-or-atom — pass `args` directly (Ecto `cast` accepts atom-keyed maps). Missing optional keys are simply not cast.

### 3. Authorization helper — `lib/graphql/helpers/authorization.ex`

Add alias `Accent.ProjectLintEntry` and:

```elixir
def project_lint_entry_authorize(action, func) do
  fn _, args, info ->
    lint_entry = Repo.get(ProjectLintEntry, args.id)

    authorize(action, lint_entry.project_id, info, do: func.(lint_entry, args, info))
  end
end
```

Mirrors `integration_authorize/2`.

### 4. Mutations — `lib/graphql/mutations/lint.ex`

Add optional `ignore` to create; add update + delete fields (reuse `:lint_entry_payload` + `build_payload`):

```elixir
field :create_project_lint_entry, :lint_entry_payload do
  arg(:project_id, non_null(:id))
  arg(:check_ids, non_null(list_of(non_null(:id))))
  arg(:type, non_null(:lint_entry_type))
  arg(:value, :string)
  arg(:ignore, :boolean)

  resolve(project_authorize(:create_project_lint_entry, &LintResolver.create_project_lint_entry/3, :project_id))
  middleware(&build_payload/2)
end

field :update_project_lint_entry, :lint_entry_payload do
  arg(:id, non_null(:id))
  arg(:check_ids, list_of(non_null(:id)))
  arg(:type, :lint_entry_type)
  arg(:value, :string)
  arg(:ignore, :boolean)

  resolve(project_lint_entry_authorize(:update_project_lint_entry, &LintResolver.update_project_lint_entry/3))
  middleware(&build_payload/2)
end

field :delete_project_lint_entry, :lint_entry_payload do
  arg(:id, non_null(:id))

  resolve(project_lint_entry_authorize(:delete_project_lint_entry, &LintResolver.delete_project_lint_entry/3))
  middleware(&build_payload/2)
end
```

Import `project_lint_entry_authorize` (already via `import Accent.GraphQL.Helpers.Authorization`).

### 5. Resolvers — `lib/graphql/resolvers/lint.ex`

```elixir
import Accent.GraphQL.Response

def update_project_lint_entry(lint_entry, args, _resolution) do
  lint_entry |> Accent.Lint.update_lint_entry(args) |> build()
end

def delete_project_lint_entry(lint_entry, _args, _resolution) do
  lint_entry |> Accent.Lint.delete_lint_entry() |> build()
end
```

`build/1` passes `{:ok, struct}` and `{:error, changeset}` straight to AbsintheErrorPayload.

### 6. Roles — `lib/accent/auth/role_abilities.ex`

Add `update_project_lint_entry` to `@write_actions` (create/delete already present).

### 7. Tests — `test/graphql/resolvers/lint_test.exs`

- `update_project_lint_entry`: insert entry, call resolver with new `value`/`ignore`/`check_ids`/`type`, assert returned struct reflects changes and DB row updated.
- `delete_project_lint_entry`: insert entry, call resolver, assert `Repo.get` returns nil.

Use `Factory.insert(ProjectLintEntry, project_id: project.id)`. Resolver returns `{:ok, struct}` (post `build/1`).

---

## Frontend (Ember, `webapp/`)

### 8. Queries

`webapp/app/queries/update-project-lint-entry.ts` (new):
```ts
import {gql} from '@apollo/client/core';

export default gql`
  mutation ProjectLintEntryUpdate(
    $id: ID!
    $checkIds: [ID!]
    $type: LintEntryType
    $value: String
    $ignore: Boolean
  ) {
    updateProjectLintEntry(id: $id checkIds: $checkIds type: $type value: $value ignore: $ignore) {
      projectLintEntry: result { id checkIds type value ignore }
      successful
      errors: messages { code field }
    }
  }
`;
```

`webapp/app/queries/delete-project-lint-entry.ts` (new):
```ts
import {gql} from '@apollo/client/core';

export default gql`
  mutation ProjectLintEntryDelete($id: ID!) {
    deleteProjectLintEntry(id: $id) {
      projectLintEntry: result { id }
      successful
      errors: messages { code field }
    }
  }
`;
```

Update `webapp/app/queries/create-project-lint-entry.ts`: add `$ignore: Boolean` arg + `ignore` in mutation call, and return full fields (`id checkIds type value ignore`).

### 9. Modal component — `webapp/app/components/project-settings/lint-entries/form-modal/`

`index.ts` (Glimmer component, ember-concurrency tasks):
- Args: `@lintEntry` (optional — present = edit mode), `@onClose`, `@onCreate`, `@onUpdate`, `@onDelete`.
- Tracked form state initialized from `@lintEntry` (or blanks for create): `value`, `ignore`, `type`, `checkIds` (array).
- Computed: `isEditMode = Boolean(this.args.lintEntry)`.
- Option lists: `typeOptions` = the 4 enum values as `{label, value}` (UPPER_SNAKE values, i18n labels); `checkOptions` = lint check enum values as `{label, value}`.
- Selected mapping: `selectedType` finds option by current value; `selectedChecks` filters options whose value is in `checkIds`.
- Handlers: `setType(option)` → `this.type = option.value`; `setChecks(options)` → `this.checkIds = options.map(o => o.value)`; `toggleIgnore()` → `this.ignore = !this.ignore`; `setValue(event)` → `this.value = event.target.value`.
- `save = dropTask`: calls `@onCreate({...})` or `@onUpdate({id, ...})` then `@onClose()` on success (no errors).
- `delete = dropTask`: `window.confirm` then `@onDelete(this.args.lintEntry.id)` then `@onClose()`.

`index.hbs`:
```hbs
<AccModal @onClose={{@onClose}} @small={{true}}>
  <div local-class='wrapper'>
    {{!-- close button (mirror add-lint-entry) --}}
    <strong local-class='title'>
      {{if this.isEditMode (t '...edit_title') (t '...new_title')}}
    </strong>

    <label local-class='field'>
      <span>{{t '...type_label'}}</span>
      <AccSelect @customSelect={{true}} @options={{this.typeOptions}} @selected={{this.selectedType}} @renderInPlace={{true}} @onchange={{this.setType}} />
    </label>

    <label local-class='field'>
      <span>{{t '...checks_label'}}</span>
      <AccSelect @multi={{true}} @options={{this.checkOptions}} @selected={{this.selectedChecks}} @renderInPlace={{true}} @onchange={{this.setChecks}} />
    </label>

    <label local-class='field'>
      <span>{{t '...value_label'}}</span>
      <input type='text' value={{this.value}} {{on 'input' this.setValue}} />
    </label>

    <label local-class='checkbox'>
      <input type='checkbox' checked={{this.ignore}} {{on 'change' this.toggleIgnore}} />
      <span>{{t '...ignore_label'}}</span>
    </label>

    <div local-class='actions'>
      {{#if this.isEditMode}}
        <AsyncButton @onClick={{perform this.delete}} @loading={{this.delete.isRunning}} class='button button--red button--filled'>
          {{t '...delete_button'}}
        </AsyncButton>
      {{/if}}
      <AsyncButton @onClick={{perform this.save}} @loading={{this.save.isRunning}} class='button button--primary button--filled'>
        {{t '...save_button'}}
      </AsyncButton>
    </div>
  </div>
</AccModal>
```

Note: `<AccSelect>` non-multi single path uses native `<select>` when `@searchEnabled`/`@customSelect`/`@multi` are all false; its `onchange` then receives the DOM target (read `.value`). To get the option object consistently, use `@customSelect={{true}}` for the type select so `setType` receives the option object. Multi path (`PowerSelectMultiple`) passes the new array to `onchange`.

`index.scss`: minimal field/label/actions/checkbox styling (mirror add-lint-entry modal + prompts form).

### 10. List + item wiring

`webapp/app/components/project-settings/lint-entries/index.hbs`:
- Track `editingEntry` (null = closed, `'new'` or an entry).
- Add "Add lint rule" button (gated `(get @permissions 'createProjectLintEntry')`) → opens modal in create mode.
- Each item gets an edit action (clicking item or an edit button) → opens modal with that entry.
- Render `<ProjectSettings::LintEntries::FormModal>` when `editingEntry` set, passing `@onCreate`/`@onUpdate`/`@onDelete`/`@onClose` from args.

`index.ts` (new, Glimmer): `@tracked editingEntry`; `openNew`, `openEdit(entry)`, `closeModal` actions.

`webapp/app/components/project-settings/lint-entries/item/index.hbs`: add an edit button (pencil icon) invoking `@onEdit @lintEntry`. Keep existing display (type/value/check badges/ignore).

The component needs `@permissions`, `@onCreate`, `@onUpdate`, `@onDelete` passed from the template → controller.

### 11. Controller — `webapp/app/controllers/logged-in/project/edit/lint-entries.ts`

Add services `intl`, `apollo-mutate`, `flash-messages`, `global-state` (permissions). Add actions:
- `createLintEntry(attrs)` → mutate `createQuery` with `{projectId: this.project.id, ...attrs}`, refetch `['ProjectLintEntries']`, flash.
- `updateLintEntry(attrs)` → mutate `updateQuery` with `{id, ...attrs}`, refetch, flash.
- `deleteLintEntry(id)` → mutate `deleteQuery` with `{id}`, refetch, flash.

Mirror prompts controller `mutateResource` helper (flash success/error based on `response.errors`).

### 12. Template — `webapp/app/templates/logged-in/project/edit/lint-entries.hbs`

Pass new args to `<ProjectSettings::LintEntries>`:
```hbs
<ProjectSettings::LintEntries
  @lintEntries={{this.lintEntries}}
  @permissions={{this.permissions}}
  @onCreate={{this.createLintEntry}}
  @onUpdate={{this.updateLintEntry}}
  @onDelete={{this.deleteLintEntry}}
/>
```

### 13. i18n — `webapp/app/locales/en-us.json` + `fr-ca.json`

Under `components.project_settings.lint_entries`:
- `new_title`, `edit_title`, `type_label`, `checks_label`, `value_label`, `ignore_label`, `save_button`, `delete_button`, `add_button`, `delete_confirm`
- type option labels (`type_all`, `type_term`, `type_key`, `type_language_tool_rule_id`)
- check option labels — reuse existing `components.translation_edit.lint_message.title_checks.*` if present, else add `check_<name>` keys.

Under `pods.project.edit.flash_messages` (or `lint_entries`): `lint_entry_create_success/error`, `lint_entry_update_success/error`, `lint_entry_remove_success/error`.

---

## Data flow

```
Modal form state ──(@onCreate/@onUpdate/@onDelete)──▶ controller action
   ▲                                                       │
   │ prefill from @lintEntry                               ▼
   │                                          apolloMutate.mutate({mutation, variables,
   │                                            refetchQueries: ['ProjectLintEntries']})
   │                                                       │
List re-renders ◀──── ProjectLintEntries refetch ─────────┘
                       + flash success/error
```

Type/checkIds convert between GraphQL UPPER_SNAKE enum values and `{label, value}` options inside the modal component.

## Error handling

- Backend invalid changeset → `build/1` returns `{:ok, changeset}` → AbsintheErrorPayload emits `successful: false` + `messages`.
- Frontend `apolloMutate` normalizes empty errors to `null`; controller flashes success/error accordingly. Modal closes only when `response.errors` is falsy.
- Delete uses `window.confirm` before mutating (mirror prompts item).

## Testing / Verification

Backend:
```bash
mix format
mix credo --strict
mix compile --warnings-as-errors --force
env $(cat .env.test.local | xargs) mix test test/graphql/resolvers/lint_test.exs
```

Frontend:
```bash
cd webapp
node node_modules/.bin/tsc        # type-check
node node_modules/.bin/ember build --output-path=<tmp>   # template/component compile
```

Manual E2E: open project → Settings → "Lint rules" → "Add lint rule" creates an entry; click an entry → modal prefilled; change value/ignore/type/checkIds → Save updates list; Delete removes it after confirm.

## Files

**Backend (modify)**
- `lib/accent/schemas/project_lint_entry.ex`
- `lib/lint/lint.ex`
- `lib/graphql/helpers/authorization.ex`
- `lib/graphql/mutations/lint.ex`
- `lib/graphql/resolvers/lint.ex`
- `lib/accent/auth/role_abilities.ex`
- `test/graphql/resolvers/lint_test.exs`

**Frontend (new)**
- `webapp/app/queries/update-project-lint-entry.ts`
- `webapp/app/queries/delete-project-lint-entry.ts`
- `webapp/app/components/project-settings/lint-entries/form-modal/index.{ts,hbs,scss}`
- `webapp/app/components/project-settings/lint-entries/index.ts`

**Frontend (modify)**
- `webapp/app/queries/create-project-lint-entry.ts`
- `webapp/app/components/project-settings/lint-entries/index.hbs`
- `webapp/app/components/project-settings/lint-entries/item/index.{hbs,scss}`
- `webapp/app/controllers/logged-in/project/edit/lint-entries.ts`
- `webapp/app/templates/logged-in/project/edit/lint-entries.hbs`
- `webapp/app/locales/en-us.json` + `fr-ca.json`
