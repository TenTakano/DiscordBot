defmodule DiscordBotWeb.LlmControllerTest do
  use DiscordBotWeb.ConnCase

  describe "POST /api/v1/llm/report-monthly-cost" do
    test "returns the total tokens and the USD cost", %{conn: conn} do
      path = "/api/v1/llm/report-monthly-cost"

      conn = post(conn, path)
      assert json_response(conn, 200) == %{"tokens" => 0, "usd_cost" => 0.0}

      DiscordBot.Llm.upsert_usage(10)

      conn = post(conn, path)
      assert json_response(conn, 200) == %{"tokens" => 10, "usd_cost" => 10.0}
    end
  end
end
