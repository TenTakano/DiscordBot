defmodule DiscordBot.Repo.Migrations.RenameAccountAuthsTableToOauthTokens do
  use Ecto.Migration

  def change do
    rename table(:account_auths), to: table(:oauth_tokens)
  end
end
