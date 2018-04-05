defmodule Accent.TranslationsCounter do
  @moduledoc """
  From documents or revisions, computed the active and conflicted translations count.
  It counts them in an efficient way (no n+1 queries).
  """

  import Ecto.Query

  alias Accent.Repo
  alias Accent.Scopes.Translation, as: Scope
  alias Accent.Translation

  @spec from_documents(list(Accent.Document.t())) :: struct
  def from_documents(documents) do
    from_assoc(documents, :document_id, &Scope.from_documents/2)
  end

  @spec from_revisions(list(Accent.Revision.t())) :: struct
  def from_revisions(revisions) do
    from_assoc(revisions, :revision_id, &Scope.from_revisions/2)
  end

  defp from_assoc(associations, assoc_name, scope_filter_ids) do
    scope =
      Translation
      |> Scope.active()
      |> Scope.no_version()

    active =
      scope
      |> select([t], %{id: field(t, ^assoc_name), active: count(t.id)})
      |> group_items(associations, assoc_name, scope_filter_ids)
      |> Repo.all()

    conflicted =
      scope
      |> Scope.conflicted()
      |> select([t], %{id: field(t, ^assoc_name), conflicted: count(t.id)})
      |> group_items(associations, assoc_name, scope_filter_ids)
      |> Repo.all()

    active
    |> Kernel.++(conflicted)
    |> Enum.group_by(&Map.get(&1, :id))
    |> Enum.reduce(%{}, &count_from_items/2)
  end

  defp count_from_items({key, items}, acc) do
    case items do
      [%{active: active}, %{conflicted: conflicted}] ->
        Map.put_new(acc, key, %{conflicted: conflicted, active: active})

      [%{active: active}] ->
        Map.put_new(acc, key, %{conflicted: 0, active: active})
    end
  end

  defp group_items(query, associations, assoc_name, scope_filter_ids) do
    association_ids = Enum.map(associations, &Map.get(&1, :id))

    from(t in query)
    |> scope_filter_ids.(association_ids)
    |> group_by([t], field(t, ^assoc_name))
  end
end
