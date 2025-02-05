defmodule DiscordBot.AccountsTest do
  use DiscordBot.DataCase

  alias DiscordBot.Accounts

  describe "find_or_create_account/1" do
    setup do
      account_params = %{
        uid: "123",
        provider: "discord",
        name: "John Doe",
        avatar: "https://example.com/avatar.png",
        token: "token",
        refresh_token: "refresh_token",
        expires_at: ~U[2025-01-18T13:02:00Z]
      }

      [account_params: account_params]
    end

    test "creates a new account", %{account_params: account_params} do
      assert {:ok, account} = Accounts.find_or_create_account(account_params)
      assert_account_resources(account)
    end

    test "finds an existing account", %{account_params: account_params} do
      assert {:ok, _account} = Accounts.find_or_create_account(account_params)

      assert {:ok, account} = Accounts.find_or_create_account(account_params)
      assert_account_resources(account)
    end

    defp assert_account_resources(account) do
      assert account.uid == "123"
      assert account.provider == "discord"
      assert account.name == "John Doe"
      assert account.avatar == "https://example.com/avatar.png"

      assert [auth] = Accounts.list_account_auth(account.id)
      assert auth.token == "token"
      assert auth.refresh_token == "refresh_token"
      assert auth.expires_at == ~U[2025-01-18T13:02:00Z]
    end
  end
end
