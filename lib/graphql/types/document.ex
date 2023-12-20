defmodule Accent.GraphQL.Types.Document do
  @moduledoc false
  use Absinthe.Schema.Notation

  object :documents do
    field(:meta, non_null(:pagination_meta))
    field(:entries, list_of(:document))
  end

  object :document do
    field(:id, non_null(:id))
    field(:path, non_null(:string))
    field(:format, non_null(:document_format))
    field(:translations_count, non_null(:integer))
    field(:translated_count, non_null(:integer))
    field(:conflicts_count, non_null(:integer))
    field(:reviewed_count, non_null(:integer))
  end
end
