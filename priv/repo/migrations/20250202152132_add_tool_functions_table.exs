defmodule DiscordBot.Repo.Migrations.AddToolFunctionsTable do
  use Ecto.Migration

  def change do
    create table(:tool_functions) do
      add :name, :string, null: false
      add :definition, :string, null: false
      add :is_enabled, :boolean, default: true

      timestamps(type: :utc_datetime)
    end
  end
end
