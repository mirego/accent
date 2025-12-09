defmodule Accent.CollaboratorCreator do
  @moduledoc false
  import Ecto.Query

  alias Accent.Collaborator
  alias Accent.Repo
  alias Accent.User
  alias Ecto.Changeset

  @max_collaborators_per_minute 5

  def create(params) do
    %Collaborator{}
    |> Collaborator.create_changeset(params)
    |> check_rate_limit()
    |> assign_user()
    |> Repo.insert()
  end

  defp assign_user(collaborator) do
    case fetch_user(collaborator.changes[:email]) do
      %User{id: id} -> Changeset.put_change(collaborator, :user_id, id)
      nil -> collaborator
    end
  end

  defp fetch_user(email) do
    Repo.get_by(User, email: email)
  end

  defp check_rate_limit(changeset) do
    assigner_id = Changeset.get_field(changeset, :assigner_id)
    one_minute_ago = DateTime.add(DateTime.utc_now(), -60, :second)

    recent_collaborators_count =
      Repo.aggregate(
        from(c in Collaborator,
          where: c.assigner_id == ^assigner_id,
          where: c.inserted_at >= ^one_minute_ago
        ),
        :count,
        :id
      )

    if recent_collaborators_count >= @max_collaborators_per_minute do
      Changeset.add_error(
        changeset,
        :assigner_id,
        "Rate limit exceeded: cannot add more than #{@max_collaborators_per_minute} collaborators per minute"
      )
    else
      changeset
    end
  end
end
