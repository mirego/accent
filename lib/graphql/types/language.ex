defmodule Accent.GraphQL.Types.Language do
  @moduledoc false
  use Absinthe.Schema.Notation

  object :language do
    field(:id, non_null(:id))
    field(:slug, non_null(:id))
    field(:name, non_null(:string))
    field(:rtl, non_null(:boolean))
  end

  object :languages do
    field(:meta, non_null(:pagination_meta))
    field(:entries, non_null(list_of(non_null(:language))))
  end
end
