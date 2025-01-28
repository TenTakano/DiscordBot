defmodule DiscordBot.Adapter.DiceTest do
  use ExUnit.Case, async: true

  alias DiscordBot.Adapter.Dice

  describe "capture_dice_roll/1" do
    test "captures dice roll" do
      assert Dice.capture_dice_roll("5d6") == %{"count" => "5", "sides" => "6"}
    end

    test "captures dice roll normalizing and downcasing input" do
      assert Dice.capture_dice_roll("5D6") == %{"count" => "5", "sides" => "6"}
      assert Dice.capture_dice_roll("５D６") == %{"count" => "5", "sides" => "6"}
    end

    test "returns nil if input is not a dice roll" do
      assert Dice.capture_dice_roll("foo") == nil
    end
  end
end
