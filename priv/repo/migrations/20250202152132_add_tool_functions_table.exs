defmodule DiscordBot.Repo.Migrations.AddToolFunctionsTable do
  use Ecto.Migration

  def change do
    create table(:tool_functions) do
      add :name, :string, null: false
      add :definition, :map, null: false
      add :is_enabled, :boolean, default: true

      timestamps(type: :utc_datetime)
    end

    create unique_index(:tool_functions, [:name])
  end
end
