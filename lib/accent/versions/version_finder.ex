defmodule Accent.VersionFinder do
  @moduledoc """
  Finds a project version by tag. The tag is either an exact tag or a requirement
  parsed by `Version.parse_requirement/1`. An exact tag match always wins; otherwise the
  highest version matching the requirement is returned.
  """

  alias Accent.Repo
  alias Accent.Scopes.Version, as: VersionScope
  alias Accent.Version

  @spec find_by_tag(String.t(), String.t()) :: Version.t() | nil
  def find_by_tag(project_id, tag) do
    versions =
      Version
      |> VersionScope.from_project(project_id)
      |> Repo.all()

    Enum.find(versions, &(&1.tag === tag)) || find_by_requirement(versions, tag)
  end

  defp find_by_requirement(versions, tag) do
    case Elixir.Version.parse_requirement(tag) do
      {:ok, requirement} ->
        versions
        |> Enum.map(&Version.with_parsed_tag/1)
        |> Enum.reject(&(&1.parsed_tag === :error))
        |> Enum.sort_by(& &1.parsed_tag, &(Elixir.Version.compare(&1, &2) === :gt))
        |> Enum.find(&Elixir.Version.match?(&1.parsed_tag, requirement))

      :error ->
        nil
    end
  end
end
