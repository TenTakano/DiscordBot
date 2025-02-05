defmodule DiscordBot.Accounts.AccountAuth do
  use DiscordBot.Schema

  schema "account_auths" do
    field :token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime

    belongs_to :account, DiscordBot.Accounts.Account

    timestamps(type: :utc_datetime)
  end

  def changeset(account_auth, attrs) do
    account_auth
    |> cast(attrs, [:token, :refresh_token, :expires_at, :account_id])
    |> validate_required([:token, :refresh_token, :expires_at, :account_id])
  end
end
