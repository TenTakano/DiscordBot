defmodule DiscordBot.Adapter.EventListener do
  use Nostrum.Consumer

  alias DiscordBot.Adapter.{Api, Dice, Ip}

  def handle_event({:MESSAGE_CREATE, %{author: %{bot: nil}} = msg, _ws_state}) do
    case get_message_type(msg) do
      :get_global_ip ->
        Api.create_message(msg.channel_id, Ip.get_global_ip())

      {:roll_dice, result} ->
        Api.create_message(msg.channel_id, generate_dice_roll_message(result, msg))

      :other ->
        :ignore
    end
  end

  def handle_event(_event), do: :ignore

  def get_message_type(%{content: "!ip"}), do: :get_global_ip

  def get_message_type(%{content: content}) do
    case Dice.capture_dice_roll(content) do
      result when is_map(result) ->
        {:roll_dice, result}

      nil ->
        :other
    end
  end

  def generate_dice_roll_message(capture, msg) do
    count = String.to_integer(capture["count"])
    sides = String.to_integer(capture["sides"])

    result = Dice.roll_dice(count, sides)
    "#{msg.author.username}: (#{count}d#{sides}) -> #{result}"
  end
end
