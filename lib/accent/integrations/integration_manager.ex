defmodule Accent.IntegrationManager do
  alias Accent.{Integration, Repo}

  import Ecto.Changeset

  @spec create(map()) :: {:ok, Integration.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    %Integration{}
    |> changeset(params)
    |> foreign_key_constraint(:user_id)
    |> Repo.insert()
  end

  @spec update(Integration.t(), map()) :: {:ok, Integration.t()} | {:error, Ecto.Changeset.t()}
  def update(integration, params) do
    integration
    |> changeset(params)
    |> Repo.update()
  end

  @spec delete(Integration.t()) :: {:ok, Integration.t()} | {:error, Ecto.Changeset.t()}
  def delete(integration) do
    integration
    |> Repo.delete()
  end

  defp changeset(model, params) do
    model
    |> cast(params, [:project_id, :user_id, :service, :events])
    |> validate_inclusion(:service, ~w(slack github discord))
    |> cast_embed(:data, with: changeset_data(params[:service] || model.service))
    |> foreign_key_constraint(:project_id)
    |> validate_required([:service, :data])
  end

  defp changeset_data("slack") do
    fn model, params ->
      model
      |> cast(params, [:url])
      |> validate_required([:url])
    end
  end

  defp changeset_data("discord") do
    fn model, params ->
      model
      |> cast(params, [:url])
      |> validate_required([:url])
    end
  end

  defp changeset_data("github") do
    fn model, params ->
      model
      |> cast(params, [:repository, :default_ref, :token])
      |> validate_required([:repository, :default_ref, :token])
    end
  end

  defp changeset_data(_) do
    fn model, params -> cast(model, params, []) end
  end
end
