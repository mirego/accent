defmodule Accent.GraphQL.Types.Activity do
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 2]
  import Accent.GraphQL.Helpers.Fields

  alias Accent.GraphQL.Resolvers.Activity, as: Resolver

  object :activity_stat do
    field(:action, non_null(:string), resolve: field_alias("action"))
    field(:count, non_null(:integer), resolve: field_alias("count"))
  end

  object :activity_previous_translation do
    field(:is_removed, :boolean, resolve: field_alias(:removed))
    field(:is_conflicted, :boolean, resolve: field_alias(:conflicted))
    field(:proposed_text, :string)
    field(:conflicted_text, :string)
    field(:value_type, :translation_value_type)

    field :text, :string, resolve: &Resolver.previous_translation_text/3
  end

  object :activity do
    field(:id, non_null(:id))
    field(:action, non_null(:string))
    field(:is_batch, non_null(:boolean), resolve: field_alias(:batch))
    field(:is_rollbacked, non_null(:boolean), resolve: field_alias(:rollbacked))
    field(:inserted_at, non_null(:datetime))
    field(:updated_at, non_null(:datetime))
    field(:activity_type, :string, resolve: &Resolver.activity_type/3)
    field(:text, :string)
    field(:stats, list_of(:activity_stat))
    field(:value_type, :translation_value_type)

    field :operations, :activities do
      arg(:page, :integer)
      arg(:page_size, :integer)

      resolve(&Accent.GraphQL.Resolvers.Activity.list_operations/3)
    end

    field(:previous_translation, :activity_previous_translation)
    field(:batch_operation, :activity, resolve: dataloader(Accent.Operation, :batch_operation))
    field(:rollbacked_operation, :activity, resolve: dataloader(Accent.Operation, :rollbacked_operation))
    field(:rollback_operation, :activity, resolve: dataloader(Accent.Operation, :rollback_operation))
    field(:user, non_null(:user), resolve: dataloader(Accent.User))
    field(:translation, :translation, resolve: dataloader(Accent.Translation))
    field(:revision, :revision, resolve: dataloader(Accent.Revision))
    field(:document, :document, resolve: dataloader(Accent.Document))
    field(:project, :project, resolve: dataloader(Accent.Project))
    field(:version, :version, resolve: dataloader(Accent.Version))
  end

  object :activities do
    field(:meta, non_null(:pagination_meta))
    field(:entries, list_of(:activity))
  end
end
