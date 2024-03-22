defmodule Accent.TelemetryUI.EctoPSQLExtras do
  @moduledoc false
  use TelemetryUI.Metrics

  @queries [
    bloat: EctoPSQLExtras.Bloat,
    cache_hit: EctoPSQLExtras.CacheHit,
    connections: EctoPSQLExtras.Connections,
    table_cache_hit: EctoPSQLExtras.TableCacheHit,
    index_cache_hit: EctoPSQLExtras.IndexCacheHit,
    index_size: EctoPSQLExtras.IndexSize,
    index_usage: EctoPSQLExtras.IndexUsage,
    records_rank: EctoPSQLExtras.RecordsRank,
    table_size: EctoPSQLExtras.TableSize,
    table_indexes_size: EctoPSQLExtras.TableIndexesSize,
    total_table_size: EctoPSQLExtras.TotalTableSize,
    unused_indexes: EctoPSQLExtras.UnusedIndexes
  ]

  def all(repo), do: Enum.map(Keyword.keys(@queries), &new(repo, &1))

  def new(repo, name, opts \\ []) do
    query_module = Keyword.fetch!(@queries, name)
    info = query_module.info()
    opts = Keyword.merge(Map.get(info, :default_args, []), opts)

    struct!(__MODULE__,
      title: info.title,
      data_resolver: fn -> {:ok, query(repo, query_module, info, opts)} end
    )
  end

  defp query(repo, query_module, info, opts) do
    result = repo.query!(query_module.query(opts), [])

    names = Enum.map(info.columns, & &1.name)
    types = Enum.map(info.columns, & &1.type)

    rows =
      if result.rows == [] do
        [["No results", nil]]
      else
        Enum.map(result.rows, &parse_row(&1, types))
      end

    {rows, names}
  end

  defp parse_row(list, types) do
    list
    |> Enum.zip(types)
    |> Enum.map(&format_value/1)
  end

  @doc false
  def format_value({%struct{} = value, _}) when struct in [Decimal, Postgrex.Interval], do: struct.to_string(value)

  def format_value({nil, _}), do: ""
  def format_value({number, :percent}), do: format_percent(number)
  def format_value({integer, :bytes}) when is_integer(integer), do: format_bytes(integer)
  def format_value({string, :string}) when is_binary(string), do: String.replace(string, "\n", "")
  def format_value({binary, _}) when is_binary(binary), do: binary
  def format_value({other, _}), do: inspect(other)

  defp format_percent(number) do
    number |> Kernel.*(100.0) |> Float.round(1) |> Float.to_string()
  end

  defp format_bytes(bytes) do
    cond do
      bytes >= memory_unit(:TB) -> format_bytes(bytes, :TB)
      bytes >= memory_unit(:GB) -> format_bytes(bytes, :GB)
      bytes >= memory_unit(:MB) -> format_bytes(bytes, :MB)
      bytes >= memory_unit(:KB) -> format_bytes(bytes, :KB)
      true -> format_bytes(bytes, :B)
    end
  end

  defp format_bytes(bytes, :B) when is_integer(bytes), do: "#{bytes} bytes"

  defp format_bytes(bytes, unit) when is_integer(bytes) do
    value = bytes / memory_unit(unit)
    "#{:erlang.float_to_binary(value, decimals: 1)} #{unit}"
  end

  defp memory_unit(:TB), do: 1024 * 1024 * 1024 * 1024
  defp memory_unit(:GB), do: 1024 * 1024 * 1024
  defp memory_unit(:MB), do: 1024 * 1024
  defp memory_unit(:KB), do: 1024

  defimpl TelemetryUI.Web.Component do
    def to_image(_metric, _, _assigns) do
      raise("not implemented")
    end

    def to_html(metric, _assigns) do
      {rows, names} = metric.data

      names =
        Enum.map_join(names, "", fn name ->
          "<td style='font-weight: bold; padding: 6px 14px; background-color: color-mix(in srgb, currentColor 20%, transparent);'>" <>
            to_string(name) <> "</td>"
        end)

      rows =
        for cells <- rows do
          "<tr style='border-bottom: 1px solid color-mix(in srgb, currentColor 10%, transparent);'>" <>
            Enum.map_join(cells, "", fn cell ->
              "<td style='padding: 6px 14px; border-right: 1px solid color-mix(in srgb, currentColor 10%, transparent); '>" <>
                cell <> "</td>"
            end) <> "</tr>"
        end

      {:safe,
       """
       <details class="relative flex flex-col bg-white dark:bg-black/40 text-slate dark:text-white p-3 pt-2 shadow">
         <summary class="flex items-baseline gap-2 text-base opacity-80 cursor-pointer">
            <h2>#{metric.title}</h2>
         </summary>

         <table class="mt-2" style='font-size: 11px; overflow-x: scroll; width: 100%; border: 1px solid color-mix(in srgb, currentColor 10%, transparent); border-bottom: 0;'>
           <thead style='border-bottom: 1px solid color-mix(in srgb, currentColor 10%, transparent);'>
             #{names}
           </thead>

           <tbody class="font-mono">
             #{rows}
           </tbody>
         </table>
       </details>
       """}
    end
  end
end
