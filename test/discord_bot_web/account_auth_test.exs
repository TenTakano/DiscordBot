defmodule DiscordBotWeb.AccountAuthTest do
  use ExUnit.Case, async: true

  alias DiscordBotWeb.AccountAuth

  describe "authenticate_api_token_impl/1" do
    test "returns the connection if the token is valid" do
      conn = %{req_headers: [{"authorization", "Bearer valid_token"}]}

      assert AccountAuth.authenticate_api_token_impl(conn) == conn
    end
  end
end
