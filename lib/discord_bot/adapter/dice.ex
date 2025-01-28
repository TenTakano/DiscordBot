defmodule DiscordBot.Adapter.Dice do
  alias DiscordBot.RandomUtil

  def capture_dice_roll(message) do
    normalized_downcase = String.normalize(message, :nfkc) |> String.downcase()
    Regex.named_captures(~r/^(?<count>\d+)d(?<sides>\d+)$/, normalized_downcase)
  end

  def roll_dice(count, sides) do
    Enum.map(1..count, fn _ -> RandomUtil.random(sides) end) |> Enum.sum()
  end
end
