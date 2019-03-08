defmodule Accent.UserRemote.TokenGiver do
  alias Accent.Repo
  alias Accent.Utils.SecureRandom

  def grant_token(user) do
    invalidate_tokens(user)

    token = create_token(user)

    {:ok, user, token}
  end

  defp invalidate_tokens(user) do
    user
    |> Ecto.assoc(:access_tokens)
    |> Repo.update_all(set: [revoked_at: DateTime.utc_now()])
  end

  defp create_token(user) do
    user
    |> Ecto.build_assoc(:access_tokens)
    |> Map.put(:token, SecureRandom.urlsafe_base64(70))
    |> Repo.insert!()
  end
end
