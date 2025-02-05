defmodule DiscordBotWeb.AuthController do
  use DiscordBotWeb, :controller
  plug Ueberauth

  alias DiscordBot.Accounts

  def callback(%{assigns: %{ueberauth_auth: %Ueberauth.Auth{} = auth}} = conn, _params) do
    auth
    |> generate_account_params()
    |> Accounts.find_or_create_account()
    |> case do
      {:ok, account} ->
        conn
        |> put_session(:account_id, account.id)
        |> put_flash(:info, "Successfully authenticated")
        |> redirect(to: "/")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to authenticate")
        |> redirect(to: "/")
    end
  end

  def callback(%{assigns: %{ueberauth_failure: %Ueberauth.Failure{}}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate")
    |> redirect(to: "/")
  end

  defp generate_account_params(auth) do
    %{
      uid: auth.uid,
      provider: Atom.to_string(auth.provider),
      name: auth.info.nickname,
      avatar: auth.info.image,
      token: auth.credentials.token,
      refresh_token: auth.credentials.refresh_token,
      expires_at: DateTime.from_unix!(auth.credentials.expires_at)
    }
  end
end
