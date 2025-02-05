defmodule DiscordBotWeb.AuthController do
  use DiscordBotWeb, :controller
  plug Ueberauth

  alias Ueberauth.Strategy.Helpers

  def request(conn, _params) do
    IO.inspect(Helpers.request_url(conn))
    redirect(conn, to: Helpers.request_url(conn))
  end

  def callback(%{assigns: %{ueberauth_failure: %Ueberauth.Failure{}}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: _auth}} = conn, _params) do
    # TODO: Implement this
    user = %{id: "12345"}

    conn
    |> put_session(:user_id, user.id)
    |> put_flash(:info, "Successfully authenticated")
    |> redirect(to: "/")
  end
end
