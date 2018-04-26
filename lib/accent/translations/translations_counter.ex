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
    Translation
    |> Scope.active()
    |> Scope.not_locked()
    |> Scope.no_version()
    |> group_items(associations, assoc_name, scope_filter_ids)
    |> select(
      [entry],
      {field(entry, ^assoc_name),
       %{
         conflicted: count(fragment("NULLIF(?, false)", entry.conflicted)),
         active: count(entry.id)
       }}
    )
    |> Repo.all()
    |> Enum.into(%{})
  end

  defp group_items(query, associations, assoc_name, scope_filter_ids) do
    association_ids = Enum.map(associations, &Map.get(&1, :id))

    from(t in query)
    |> scope_filter_ids.(association_ids)
    |> group_by([t], field(t, ^assoc_name))
  end
end
