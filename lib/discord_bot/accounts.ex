defmodule DiscordBot.Accounts do
  import Ecto.Query

  alias DiscordBot.Repo
  alias DiscordBot.Accounts.{Account, AccountAuth}

  def find_or_create_account(account_params) do
    case Repo.get_by(Account, provider: account_params.provider, uid: account_params.uid) do
      nil ->
        with {:ok, account} <- create_account(account_params),
             {:ok, _account_auth} <-
               Map.put(account_params, :account_id, account.id) |> create_account_auth() do
          {:ok, account}
        end

      account ->
        {:ok, account}
    end
  end

  def create_account(account_params) do
    %Account{}
    |> Account.changeset(account_params)
    |> Repo.insert()
  end

  def create_account_auth(account_auth_params) do
    %AccountAuth{}
    |> AccountAuth.changeset(account_auth_params)
    |> Repo.insert()
  end

  def list_account_auth(account_id) do
    Repo.all(from a in AccountAuth, where: a.account_id == ^account_id)
  end
end
