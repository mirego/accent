defmodule Accent.BadgeGenerator do
  alias Accent.{PrettyFloat, Repo}
  alias Accent.Scopes.Revision, as: RevisionScope

  @badge_service_timeout 20_000
  @base_badge_service_url "https://img.shields.io/badge/"

  def generate(project, attribute) do
    project_stats =
      project
      |> Ecto.assoc(:revisions)
      |> RevisionScope.with_stats()
      |> Repo.all()
      |> merge_project_stats()

    color = color_for_value(project_stats[attribute], attribute)

    (@base_badge_service_url <> "accent-#{label(project_stats[attribute], attribute)}-#{color}.svg")
    |> HTTPoison.get([], recv_timeout: @badge_service_timeout)
    |> case do
      {:ok, %{body: body}} -> {:ok, body}
      _ -> {:error, "internal error"}
    end
  end

  defp color_for_value(value, :percentage_reviewed_count) when value < 50, do: "d84444"
  defp color_for_value(value, :percentage_reviewed_count) when value <= 75, do: "e4b600"
  defp color_for_value(_value, :percentage_reviewed_count), do: "45c86f"
  defp color_for_value(_value, _), do: "aaaaaa"

  defp label(value, :percentage_reviewed_count), do: "#{value}%25"
  defp label(value, :translations_count), do: "#{value}%20strings"
  defp label(value, :reviewed_count), do: "#{value}%20reviewed"
  defp label(value, :conflicts_count), do: "#{value}%20conflicts"

  defp merge_project_stats(revisions) do
    revisions
    |> Enum.reduce(%{translations_count: 0, conflicts_count: 0, reviewed_count: 0}, fn revision, acc ->
      acc
      |> Map.put(:translations_count, acc[:translations_count] + revision.translations_count)
      |> Map.put(:conflicts_count, acc[:conflicts_count] + revision.conflicts_count)
      |> Map.put(:reviewed_count, acc[:reviewed_count] + revision.reviewed_count)
    end)
    |> (fn
          stats = %{translations_count: 0} ->
            Map.put(stats, :percentage_reviewed_count, 0)

          stats ->
            percentage_reviewed =
              stats[:reviewed_count]
              |> Kernel./(stats[:translations_count])
              |> Kernel.*(100)
              |> Float.round(2)
              |> PrettyFloat.convert()

            Map.put(stats, :percentage_reviewed_count, percentage_reviewed)
        end).()
  end
end
