defmodule Accent.User do
  use Accent.Schema

  schema "users" do
    field(:email, :string)
    field(:fullname, :string)
    field(:picture_url, :string)
    field(:bot, :boolean, default: false)

    has_one(:global_access_token, Accent.AccessToken, where: [revoked_at: nil, global: true])
    has_many(:access_tokens, Accent.AccessToken)
    has_many(:private_access_tokens, Accent.AccessToken, where: [global: false])
    has_many(:auth_providers, Accent.AuthProvider)
    has_many(:collaborations, Accent.Collaborator)
    has_many(:bot_collaborations, Accent.Collaborator, where: [role: "bot"])
    has_many(:collaboration_assigns, Accent.Collaborator, foreign_key: :assigner_id)

    field(:permissions, :map, virtual: true)

    timestamps()
  end

  @doc """
  ## Examples

    iex> Accent.User.name_with_fallback(%{fullname: "test", email: "foo@bar.com"})
    "test"
    iex> Accent.User.name_with_fallback(%{fullname: nil, email: "foo@bar.com"})
    "foo@bar.com"
  """
  def name_with_fallback(%{fullname: fullname, email: email}) when is_nil(fullname), do: email
  def name_with_fallback(%{fullname: fullname}), do: fullname
end
