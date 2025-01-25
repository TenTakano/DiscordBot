defmodule DiscordBot.Adapter.Dice do
  def filter_and_roll_dice(content) do
    normalized_downcase = String.normalize(content, :nfkc) |> String.downcase()

    with %{"count" => count, "sides" => sides} <-
           Regex.named_captures(~r/^(?<count>\d+)d(?<sides>\d+)$/, normalized_downcase) do
      roll_dice(String.to_integer(count), String.to_integer(sides))
    end
  end

  defp roll_dice(count, sides) do
    Enum.map(1..count, fn _ -> :rand.uniform(sides) end) |> Enum.sum()
  end
end
