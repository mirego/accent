defmodule Accent.GraphQL.Paginated do
  @moduledoc false
  use Accessible

  alias Accent.Repo
  alias Ecto.Query

  require Query

  defmodule Meta do
    @moduledoc false
    @type t :: %__MODULE__{}

    @enforce_keys [:current_page, :total_pages, :total_entries, :next_page, :previous_page]
    defstruct current_page: 0, total_entries: 0, total_pages: 0, next_page: nil, previous_page: nil
  end

  @type t(list_of_type) :: %__MODULE__{entries: [list_of_type], meta: Meta.t(), nodes: list() | nil}

  @enforce_keys [:entries, :meta]
  defstruct entries: [], meta: %{}, nodes: nil

  @default_page_size 30
  @max_page_size 10_000

  def paginate(query, args, options \\ []) do
    {info, options} = Keyword.pop(options, :info)

    if meta_requested?(info) do
      Repo.paginate(query, page: args[:page], page_size: args[:page_size], options: options)
    else
      paginate_without_count(query, args, options)
    end
  end

  defp paginate_without_count(query, args, options) do
    page_size = min(positive_integer(args[:page_size], @default_page_size), @max_page_size)
    page_number = positive_integer(args[:page], 1)

    entries =
      query
      |> Query.offset(^(page_size * (page_number - 1)))
      |> Query.limit(^page_size)
      |> Repo.all()

    if entries == [] and page_number > 1 do
      Repo.paginate(query, page: page_number, page_size: page_size, options: options)
    else
      %Scrivener.Page{
        entries: entries,
        page_number: page_number,
        page_size: page_size,
        total_entries: 0,
        total_pages: 1
      }
    end
  end

  defp positive_integer(value, _default) when is_integer(value) and value > 0, do: value
  defp positive_integer(_value, default), do: default

  defp meta_requested?(%Absinthe.Resolution{} = info) do
    info
    |> Absinthe.Resolution.project()
    |> Enum.any?(&(&1.name == "meta"))
  end

  defp meta_requested?(_), do: true

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
