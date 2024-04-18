defmodule Accent.GraphQL.Mutations.Lint do
  @moduledoc false
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload
  import Accent.GraphQL.Helpers.Authorization

  alias Accent.GraphQL.Resolvers.Lint, as: LintResolver

  payload_object(:lint_entry_payload, :project_lint_entry)

  enum :lint_entry_type do
    value(:all)
    value(:term)
    value(:key)
    value(:language_tool_rule_id)
  end

  object :lint_mutations do
    field :create_project_lint_entry, :lint_entry_payload do
      arg(:project_id, non_null(:id))
      arg(:check_ids, non_null(list_of(non_null(:id))))
      arg(:type, non_null(:lint_entry_type))
      arg(:value, :string)

      resolve(project_authorize(:create_project_lint_entry, &LintResolver.create_project_lint_entry/3, :project_id))
      middleware(&build_payload/2)
    end
  end
end
