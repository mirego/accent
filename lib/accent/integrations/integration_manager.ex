defmodule Accent.IntegrationManager do
  @moduledoc false
  import Ecto.Changeset

  alias Accent.Integration
  alias Accent.Repo
  alias Accent.User

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

  @spec execute(Integration.t(), User.t(), map()) :: {:ok, Integration.t()}
  def execute(integration, user, params) do
    case execute_integration(integration, user, params) do
      :ok ->
        integration
        |> change(%{last_executed_at: DateTime.utc_now(), last_executed_by_user_id: user.id})
        |> force_change(:updated_at, integration.updated_at)
        |> Repo.update!()

      _ ->
        :ok
    end

    {:ok, integration}
  end

  @spec delete(Integration.t()) :: {:ok, Integration.t()} | {:error, Ecto.Changeset.t()}
  def delete(integration) do
    Repo.delete(integration)
  end

  defp changeset(model, params) do
    model
    |> cast(params, [:project_id, :user_id, :service, :events])
    |> validate_inclusion(:service, ~w(slack github discord azure_storage_container aws_s3))
    |> cast_embed(:data, with: changeset_data(params[:service] || model.service))
    |> foreign_key_constraint(:project_id)
    |> validate_required([:service, :data])
  end

  defp execute_integration(%{service: "azure_storage_container"} = integration, user, params) do
    Accent.IntegrationManager.Execute.AzureStorageContainer.upload_translations(
      integration,
      user,
      params[:azure_storage_container]
    )

    :ok
  end

  defp execute_integration(%{service: "aws_s3"} = integration, user, params) do
    Accent.IntegrationManager.Execute.AWSS3.upload_translations(
      integration,
      user,
      params[:aws_s3]
    )

    :ok
  end

  defp execute_integration(_integration, _user, _params) do
    :noop
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

  defp changeset_data("azure_storage_container") do
    fn model, params ->
      model
      |> cast(params, [:azure_storage_container_sas])
      |> validate_required([:azure_storage_container_sas])
    end
  end

  defp changeset_data("aws_s3") do
    fn model, params ->
      model
      |> cast(params, [
        :aws_s3_bucket,
        :aws_s3_path_prefix,
        :aws_s3_region,
        :aws_s3_access_key_id,
        :aws_s3_secret_access_key
      ])
      |> validate_required([
        :aws_s3_bucket,
        :aws_s3_path_prefix,
        :aws_s3_region,
        :aws_s3_access_key_id,
        :aws_s3_secret_access_key
      ])
    end
  end

  defp changeset_data(_) do
    fn model, params -> cast(model, params, []) end
  end
end
