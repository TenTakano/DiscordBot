defmodule DiscordBotWeb.AccountAuth do
  import Plug.Conn

  if Mix.env() == :test do
    def authenticate_api_token(conn, _opts), do: conn
  else
    def authenticate_api_token(conn, _opts), do: authenticate_api_token_impl(conn)
  end

  def authenticate_api_token_impl(conn) do
    with {:ok, _token} <- fetch_token(conn) do
      conn
    else
      {:error, _} ->
        conn
        |> put_status(:unauthorized)
        |> halt()
    end
  end

  defp fetch_token(%{req_headers: headers}) do
    case Enum.find(headers, fn {key, _} -> key == "authorization" end) do
      {"authorization", "Bearer " <> token} ->
        {:ok, token}

      {"authorization", _token} ->
        {:error, :invalid_token}

      _ ->
        {:error, :no_token}
    end
  end

  defp fetch_token(_conn), do: {:error, :no_token}
end
