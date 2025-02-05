defmodule DiscordBot.Accounts do
  alias DiscordBot.Repo
  alias DiscordBot.Accounts.Account

  def find_or_create_account(account_params) do
    case Repo.get_by(Account, provider: account_params.provider, uid: account_params.uid) do
      nil ->
        create_account(account_params)

      account ->
        {:ok, account}
    end
  end

  def create_account(account_params) do
    %Account{}
    |> Account.changeset(account_params)
    |> Repo.insert()
  end
end
