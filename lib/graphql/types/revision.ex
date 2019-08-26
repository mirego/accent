defmodule Accent.GraphQL.Types.Revision do
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]
  import Accent.GraphQL.Helpers.Authorization
  import Accent.GraphQL.Helpers.Fields

  object :revision do
    field(:id, :id)
    field(:is_master, non_null(:boolean), resolve: field_alias(:master))
    field(:translations_count, non_null(:integer))
    field(:conflicts_count, non_null(:integer))
    field(:reviewed_count, non_null(:integer))
    field(:inserted_at, non_null(:datetime))

    field(:name, :string)
    field(:slug, :string)

    field(:language, non_null(:language), resolve: dataloader(Accent.Language))

    field :translations, non_null(:translations) do
      arg(:page, :integer)
      arg(:page_size, :integer)
      arg(:order, :string)
      arg(:document, :id)
      arg(:version, :id)
      arg(:query, :string)
      arg(:is_conflicted, :boolean)
      arg(:is_text_empty, :boolean)
      arg(:is_text_not_empty, :boolean)
      arg(:is_added_last_sync, :boolean)
      arg(:is_commented_on, :boolean)
      arg(:reference_revision, :id)

      resolve(revision_authorize(:index_translations, &Accent.GraphQL.Resolvers.Translation.list_revision/3))
    end
  end
end
