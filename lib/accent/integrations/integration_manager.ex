defmodule Accent.IntegrationManager do
  @moduledoc false
  import Ecto.Changeset

  alias Accent.Integration
  alias Accent.Repo

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
    Repo.delete(integration)
  end

  defp changeset(model, params) do
    model
    |> cast(params, [:project_id, :user_id, :service, :events])
    |> validate_inclusion(:service, ~w(slack github discord azure))
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

  defp changeset_data("azure") do
    fn model, params ->
      model
      |> cast(params, [:account_name, :account_key, :container_name])
      |> validate_required([:account_name, :account_key, :container_name])
    end
  end

  defp changeset_data(_) do
    fn model, params -> cast(model, params, []) end
  end
end
