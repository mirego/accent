defmodule Accent.UserRemote.Authenticator do
  alias Accent.UserRemote.{CollaboratorNormalizer, Persister, TokenGiver, User}

  def authenticate(%{provider: provider, info: info}) do
    info
    |> map_user(provider)
    |> Persister.persist()
    |> CollaboratorNormalizer.normalize()
    |> TokenGiver.grant_token()
  end

  defp map_user(info, :dummy) do
    %User{
      provider: "dummy",
      fullname: info.email,
      email: normalize_email(info.email),
      uid: normalize_email(info.email)
    }
  end

  defp map_user(info, provider) do
    %User{
      provider: to_string(provider),
      fullname: info.name,
      picture_url: info.image,
      email: normalize_email(info.email),
      uid: normalize_email(info.email)
    }
  end

  defp normalize_email(email) do
    String.downcase(email)
  end
end
