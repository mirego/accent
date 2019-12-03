defmodule Accent.ProjectCreator do
  import Ecto.Changeset

  alias Accent.{Project, Repo, User, UserRemote.TokenGiver}
  alias Ecto.Changeset

  @required_fields ~w(name main_color language_id)a
  @optional_fields ~w(logo)a
  @bot %User{fullname: "API Client", bot: true}

  def create(params: params, user: user) do
    changeset =
      with changeset = %Changeset{valid?: true} <- cast_changeset(%Project{}, params),
           changeset = %Changeset{valid?: true} <- build_master_revision(changeset),
           changeset = %Changeset{valid?: true} <- build_collaborations(changeset, user),
           do: changeset

    Repo.insert(changeset)
  end

  def cast_changeset(model, params) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def build_master_revision(changeset) do
    revision =
      Ecto.build_assoc(changeset.data, :revisions, %{
        language_id: changeset.params["language_id"],
        master: true
      })

    put_assoc(changeset, :revisions, [revision])
  end

  def build_collaborations(changeset, user) do
    bot_user = generate_bot_user_with_access()

    bot = Ecto.build_assoc(changeset.data, :collaborators, %{role: "bot", email: bot_user.email, user_id: bot_user.id})
    owner = Ecto.build_assoc(changeset.data, :collaborators, %{role: "owner", email: user.email, user_id: user.id})

    put_assoc(changeset, :collaborators, [owner, bot])
  end

  def generate_bot_user_with_access do
    user = Repo.insert!(@bot)
    {:ok, _token} = TokenGiver.grant_token(user)

    user
  end
end
