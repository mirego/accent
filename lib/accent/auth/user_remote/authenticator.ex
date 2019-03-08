defmodule Accent.UserRemote.Authenticator do
  alias Accent.UserRemote.{CollaboratorNormalizer, Fetcher, Persister, TokenGiver}

  def authenticate(provider, uid) do
    provider
    |> fetch(uid)
    |> persist
    |> normalize_collaborators
    |> grant_token
  end

  defp fetch(provider, uid), do: Fetcher.fetch(provider, uid)

  defp persist({:error, error}), do: {:error, error}
  defp persist({:ok, user}), do: Persister.persist(user)

  defp normalize_collaborators({:error, error}), do: {:error, error}

  defp normalize_collaborators({:ok, user, provider}) do
    CollaboratorNormalizer.normalize(user)

    {:ok, user, provider}
  end

  defp grant_token({:error, error}), do: {:error, error}
  defp grant_token({:ok, user, _provider}), do: TokenGiver.grant_token(user)
end
