defmodule DiscordBotWeb.AccountAuthTest do
  use ExUnit.Case, async: true

  alias DiscordBotWeb.AccountAuth

  describe "authenticate_api_token_impl/1" do
    setup do
      [conn: Phoenix.ConnTest.build_conn()]
    end

    test "returns the connection if the token is valid", %{conn: conn} do
      conn = %{conn | req_headers: [{"authorization", "Bearer valid_token"}]}

      assert AccountAuth.authenticate_api_token_impl(conn) == conn
    end

    test "returns an authorized response if the token is invalid", %{conn: conn} do
      Enum.each(
        [
          %{conn | req_headers: [{"authorization", "Bearer invalid_token"}]},
          %{conn | req_headers: [{"authorization", "Bearervalid_token"}]},
          %{conn | req_headers: []}
        ],
        fn conn ->
          assert %{status: 401, resp_body: body} = AccountAuth.authenticate_api_token_impl(conn)
          assert Jason.decode!(body) == %{"error" => "Authentication failed"}
        end
      )
    end
  end
end
