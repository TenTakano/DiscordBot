defmodule DiscordBot.Adapter.EventListenerTest do
  use ExUnit.Case

  import Mox

  alias DiscordBot.Adapter.EventListener
  alias DiscordBot.Adapter.Api.Mock

  setup :verify_on_exit!

  describe "need_evaluate?/1" do
    test "returns {:ok, false, content} if message does not contain any mentions" do
      assert EventListener.need_evaluate?("foo") == {:ok, false, "foo"}
    end

    test "returns {:ok, true, content} if message contains mention for me" do
      expect(Mock, :get_current_user!, 3, fn -> %{id: "123"} end)

      Enum.each(
        [
          "<@123> foo",
          "<@123> <@456> foo",
          "<@456> <@123> foo"
        ],
        fn content ->
          assert EventListener.need_evaluate?(content) == {:ok, true, "foo"}
        end
      )
    end
  end

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
