defmodule Accent.GraphQL.Types.Activity do
  use Absinthe.Schema.Notation

  alias Accent.Repo
  alias Accent.GraphQL.Paginated

  import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 2]
  import Accent.GraphQL.Helpers.Fields

  object :activity_stat do
    field(:action, non_null(:string), resolve: field_alias("action"))
    field(:count, non_null(:integer), resolve: field_alias("count"))
  end

  object :activity_previous_translation do
    field :value_type, :translation_value_type do
      resolve(fn
        %{"value_type" => ""}, _, _ -> {:ok, "string"}
        %{"value_type" => nil}, _, _ -> {:ok, "string"}
        %{"value_type" => value_type}, _, _ -> {:ok, value_type}
        _, _, _ -> {:ok, "empty"}
      end)
    end

    field(:is_removed, :boolean, resolve: field_alias(:removed))
    field(:is_conflicted, :boolean, resolve: field_alias(:conflicted))
    field(:proposed_text, :string)
    field(:conflicted_text, :string)

    field :text, :string do
      resolve(fn previous_translation, _, _ ->
        {:ok, previous_translation.corrected_text || previous_translation.proposed_text}
      end)
    end
  end

  object :activity do
    field(:id, non_null(:id))
    field(:action, non_null(:string))
    field(:is_batch, non_null(:boolean), resolve: field_alias(:batch))
    field(:is_rollbacked, non_null(:boolean), resolve: field_alias(:rollbacked))
    field(:inserted_at, non_null(:datetime))
    field(:updated_at, non_null(:datetime))

    field(
      :activity_type,
      :string,
      resolve: fn activity, _, _ ->
        case activity do
          %{translation_id: id} when not is_nil(id) -> {:ok, :translation}
          %{revision_id: id} when not is_nil(id) -> {:ok, :revision}
          _ -> {:ok, :project}
        end
      end
    )

    field(:text, :string)
    field(:stats, list_of(:activity_stat))

    field :value_type, non_null(:translation_value_type) do
      resolve(fn
        %{value_type: ""}, _, _ -> {:ok, "string"}
        %{value_type: nil}, _, _ -> {:ok, "string"}
        %{value_type: value_type}, _, _ -> {:ok, value_type}
        _, _, _ -> {:ok, "empty"}
      end)
    end

    field :operations, :activities do
      arg(:page, :integer)

      resolve(fn activity, args, _ ->
        activity
        |> Ecto.assoc(:operations)
        |> Repo.paginate(page: args[:page])
        |> Paginated.format()
        |> (&{:ok, &1}).()
      end)
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
