defmodule DiscordBot.Accounts.Account do
  use DiscordBot.Schema

  schema "accounts" do
    field :uid, :string
    field :provider, :string
    field :name, :string
    field :avatar, :string

    has_many :account_auths, DiscordBot.Accounts.OAuthToken

    timestamps(type: :utc_datetime)
  end

  def changeset(account, attrs) do
    account
    |> cast(attrs, [:uid, :provider, :name, :avatar])
    |> validate_required([:uid, :provider])
    |> unique_constraint([:uid, :provider])
  end
end
