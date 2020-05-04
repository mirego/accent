defmodule Accent.GraphQL.Paginated do
  defmodule Meta do
    @type t :: %__MODULE__{}

    @enforce_keys [:current_page, :total_pages, :total_entries, :next_page, :previous_page]
    defstruct current_page: 0, total_entries: 0, total_pages: 0, next_page: nil, previous_page: nil
  end

  @type t(list_of_type) :: %__MODULE__{entries: [list_of_type], meta: Meta.t()}

  @enforce_keys [:entries, :meta]
  defstruct entries: [], meta: %{}

  use Accessible

  def paginate(query, args) do
    Accent.Repo.paginate(query, page: args[:page], page_size: args[:page_size])
  end

  def format(paginated_list) do
    %__MODULE__{entries: paginated_list.entries, meta: meta(paginated_list)}
  end

  defp meta(%{page_size: page_size, total_entries: total_entries, total_pages: total_pages, page_number: page_number}) do
    %Meta{
      current_page: page_number,
      total_entries: total_entries,
      total_pages: total_pages,
      next_page: build_next_page(page_size, total_entries, total_pages, page_number),
      previous_page: build_previous_page(page_size, total_entries, total_pages, page_number)
    }
  end

  defp build_next_page(_page_size, _entries, 1, _page), do: nil
  defp build_next_page(_page_size, _entries, pages, page) when page >= pages, do: nil

  defp build_next_page(page_size, entries, _pages, page) do
    if page_size * page < entries, do: page + 1
  end

  defp build_previous_page(_page_size, _entries, _pages, 1), do: nil
  defp build_previous_page(_page_size, _entries, 1, _page), do: nil

  defp build_previous_page(page_size, entries, _pages, page) do
    if page_size * page < entries + page_size, do: page - 1
  end
end
