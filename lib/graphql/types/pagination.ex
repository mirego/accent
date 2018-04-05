defmodule Accent.GraphQL.Types.Pagination do
  use Absinthe.Schema.Notation

  object :pagination_meta do
    field(:current_page, non_null(:integer))
    field(:previous_page, :integer)
    field(:next_page, :integer)
    field(:total_entries, non_null(:integer))
    field(:total_pages, non_null(:integer))
  end
end
