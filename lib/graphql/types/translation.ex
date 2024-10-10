defmodule Accent.GraphQL.Types.Translation do
  @moduledoc false
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 2]
  import Accent.GraphQL.Helpers.Authorization
  import Accent.GraphQL.Helpers.Fields

  alias Accent.GraphQL.Resolvers.Translation

  enum :translation_value_type do
    value(:string, as: "string")
    value(:html, as: "html")
    value(:plural, as: "plural")
    value(:boolean, as: "boolean")
    value(:null, as: "null")
    value(:array, as: "array")
    value(:empty, as: "empty")
    value(:integer, as: "integer")
    value(:float, as: "float")
  end

  object :grouped_translation do
    field(:key, non_null(:string), resolve: &Translation.key/3)
    field(:document, non_null(:document), resolve: &Translation.batch_document/3)

    field(:translations, non_null(list_of(non_null(:translation))), resolve: &Translation.batch_translation_ids/3)
  end

  object :translation do
    field(:id, non_null(:id))
    field(:key, non_null(:string), resolve: &Translation.key/3)
    field(:value_type, non_null(:translation_value_type))
    field(:plural, non_null(:boolean))

    field(:file_comment, :string,
      resolve: fn
        %{file_comment: nil}, _, _ -> {:ok, nil}
        %{file_comment: value}, _, _ -> {:ok, String.trim(value)}
      end
    )

    field(:placeholders, non_null(list_of(non_null(:string))))

    field(:proposed_text, :string)
    field(:corrected_text, :string)
    field(:conflicted_text, :string)
    field(:is_conflicted, non_null(:boolean), resolve: field_alias(:conflicted))
    field(:is_translated, non_null(:boolean), resolve: field_alias(:translated))
    field(:is_removed, non_null(:boolean), resolve: field_alias(:removed))
    field(:related_translation, :translation)
    field(:comments_count, non_null(:integer))
    field(:updated_at, non_null(:datetime))

    field(:document, :document, resolve: dataloader(Accent.Document))
    field(:revision, :revision, resolve: dataloader(Accent.Revision))
    field(:version, :version, resolve: dataloader(Accent.Version))

    field(:source_translation, :translation, resolve: dataloader(Accent.Translation, :source_translation))

    field :lint_messages, non_null(list_of(non_null(:lint_translation_message))) do
      arg(:text, :string)

      resolve(translation_authorize(:lint, &Accent.GraphQL.Resolvers.Lint.lint_translation/3))
    end

    field(:master_translation, :translation) do
      resolve(&Translation.master_translation/3)
    end

    field :comments_subscriptions, list_of(:translation_comments_subscription) do
      resolve(
        translation_authorize(
          :index_translation_comments_subscriptions,
          dataloader(Accent.TranslationCommentsSubscription, :comments_subscriptions)
        )
      )
    end

    field :comments, :comments do
      arg(:page, :integer)
      arg(:page_size, :integer)

      resolve(
        translation_authorize(
          :index_comments,
          &Accent.GraphQL.Resolvers.Comment.list_translation/3
        )
      )
    end

    field :activities, :activities do
      arg(:page, :integer)
      arg(:page_size, :integer)
      arg(:action, :string)
      arg(:is_batch, :boolean)
      arg(:user_id, :id)
      arg(:version_id, :id)

      resolve(
        translation_authorize(
          :index_translation_activities,
          &Accent.GraphQL.Resolvers.Activity.list_translation/3
        )
      )
    end

    field :editions, list_of(:translation) do
      resolve(
        translation_authorize(
          :index_translation_editions,
          &Translation.editions/3
        )
      )
    end

    field :related_translations, list_of(:translation) do
      resolve(
        translation_authorize(
          :index_translation_related,
          &Translation.related_translations/3
        )
      )
    end
  end

  object :translations do
    field(:meta, :pagination_meta)
    field(:entries, list_of(:translation))
  end

  object :grouped_translations do
    field(:meta, non_null(:pagination_meta))
    field(:entries, non_null(list_of(non_null(:grouped_translation))))
    field(:revisions, non_null(list_of(non_null(:revision))))
  end
end
