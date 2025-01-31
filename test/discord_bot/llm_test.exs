defmodule DiscordBot.LlmTest do
  use DiscordBot.DataCase, async: true

  alias DiscordBot.Llm

  describe "upsert_usage/1" do
    test "creates a new usage record if none exists" do
      assert Llm.upsert_usage(10) == 10
      assert Llm.get_total_usage() == 10
    end

    test "increments the total tokens if a usage record exists" do
      Llm.upsert_usage(10)

      assert Llm.upsert_usage(10) == 20
      assert Llm.get_total_usage() == 20
    end
  end
end
