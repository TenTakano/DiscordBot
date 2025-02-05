defmodule DiscordBot.Repo.Migrations.AddAccountsTable do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :uid, :string
      add :provider, :string
      add :name, :string
      add :avatar, :string

      timestamps(type: :utc_datetime)
    end

    create table(:account_auths) do
      add :token, :string
      add :refresh_token, :string
      add :expires_at, :utc_datetime

      add :account_id, references(:accounts, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:accounts, [:uid, :provider])
  end
end
