defmodule DiscordBot.Adapter.DiceTest do
  use ExUnit.Case, async: true

  import Mox

  alias DiscordBot.Adapter.Dice
  alias DiscordBot.RandomUtil.Mock

  setup :verify_on_exit!

  describe "filter_and_roll_dice/1" do
    test "rolls dice" do
      expect(Mock, :random, 5, fn _ -> 3 end)

      assert Dice.filter_and_roll_dice("5d6") == "(5d6) -> 15"
    end

    test "rolls dice normalizing and downcasing input" do
      stub(Mock, :random, fn _ -> 3 end)

      assert Dice.filter_and_roll_dice("5D6") == "(5d6) -> 15"
      assert Dice.filter_and_roll_dice("５D６") == "(5d6) -> 15"
    end

    test "returns nil if input is not a dice roll" do
      assert Dice.filter_and_roll_dice("foo") == nil
    end
  end
end
