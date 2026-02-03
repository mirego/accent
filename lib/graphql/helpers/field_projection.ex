defmodule Accent.GraphQL.Helpers.FieldProjection do
  @moduledoc """
  Helper to check if specific fields are requested in a GraphQL query.
  Used to skip expensive computations when their results aren't needed.
  """

  @count_fields ~w(
      translations_count
      conflicts_count
      reviewed_count
      translated_count
      translationsCount
      conflictsCount
      reviewedCount
      translatedCount
  )

  @doc """
  Returns true if none of the count fields are requested in the query.

  Handles paginated responses by looking inside "entries" field when present.

  ## Examples

      # When count fields are not requested, skip stats computation
      skip_stats?(info) #=> true

      # When at least one count field is requested, compute stats
      skip_stats?(info) #=> false
  """
  @spec skip_stats?(Absinthe.Resolution.t() | map()) :: boolean()
  def skip_stats?(%{definition: _} = info) do
    requested_fields = get_requested_fields(info)
    Enum.all?(@count_fields, &(&1 not in requested_fields))
  end

  def skip_stats?(_info), do: false

  defp get_requested_fields(info) do
    projected = Absinthe.Resolution.project(info)
    entries_field = Enum.find(projected, &(&1.name == "entries"))

    if entries_field do
      Enum.map(entries_field.selections, & &1.name)
    else
      Enum.map(projected, & &1.name)
    end
  end
end
