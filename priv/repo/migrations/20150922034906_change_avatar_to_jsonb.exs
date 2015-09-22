defmodule FileUpload.Repo.Migrations.ChangeAvatarToJsonb do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :avatar
      add :avatar, :jsonb
    end
  end
end
