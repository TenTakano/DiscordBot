defmodule DiscordBot.Accounts.Account do
  use DiscordBot.Schema

  schema "accounts" do
    field :uid, :string
    field :provider, :string
    field :name, :string
    field :avatar, :string
    field :token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  def changeset(account, attrs) do
    account
    |> cast(attrs, [:uid, :provider, :name, :avatar, :token, :refresh_token, :expires_at])
    |> validate_required([:uid, :provider])
    |> unique_constraint([:uid, :provider])
  end
end
