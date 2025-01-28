defmodule DiscordBot.Adapter.EventListenerTest do
  use ExUnit.Case

  alias DiscordBot.Adapter.EventListener

  describe "get_message_type/1" do
    test "returns :get_global_ip if message content is '!ip'" do
      assert EventListener.get_message_type(%{content: "!ip"}) == :get_global_ip
    end

    test "returns {:roll_dice, result} if message content is a dice roll" do
      assert EventListener.get_message_type(%{content: "5d6"}) ==
               {:roll_dice, %{"count" => "5", "sides" => "6"}}
    end

    test "returns :other if message content is not '!ip' or a dice roll" do
      assert EventListener.get_message_type(%{content: "foo"}) == :other
    end
  end
end
