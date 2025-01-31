defmodule DiscordBot.Repo.Migrations.AddTokenUsageTable do
  use Ecto.Migration

  def change do
    create table(:llm_usages) do
      add :total_tokens, :integer, default: 0

      timestamps(type: :utc_datetime)
    end
  end
end
