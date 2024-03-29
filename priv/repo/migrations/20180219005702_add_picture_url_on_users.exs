defmodule Accent.Repo.Migrations.AddPictureUrlOnUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:picture_url, :text)
    end
  end
end
