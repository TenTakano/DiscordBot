defmodule DiscordBotWeb.LlmControllerTest do
  use DiscordBotWeb.ConnCase

  describe "POST /api/v1/llm/report-monthly-cost" do
    setup %{conn: conn} do
      [conn: conn, path: "/api/v1/llm/report-monthly-cost"]
    end

    test "returns the total tokens and the USD cost", %{conn: conn, path: path} do
      conn = post(conn, path)
      assert json_response(conn, 200) == %{"tokens" => 0, "usd_cost" => 0.0}

      DiscordBot.Llm.upsert_usage(10)

      conn = post(conn, path)
      assert json_response(conn, 200) == %{"tokens" => 10, "usd_cost" => 10.0}
    end

    test "resets the total tokens if the reset parameter is true", %{conn: conn, path: path} do
      DiscordBot.Llm.upsert_usage(10)
      conn = post(conn, path, %{reset: true})

      assert json_response(conn, 200) == %{"tokens" => 10, "usd_cost" => 10.0}
      assert DiscordBot.Llm.get_total_usage() == 0
    end

    test "returns an error if the reset parameter is not a boolean", %{conn: conn, path: path} do
      conn = post(conn, path, %{reset: "true"})
      assert json_response(conn, 400) == %{"error" => "Invalid parameters"}
    end
  end
end
