defmodule DiscordBot.Adapter.EventListener do
  use Nostrum.Consumer

  alias DiscordBot.Adapter.{Api, Ip}

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!ip" ->
        Api.create_message(msg.channel_id, Ip.get_global_ip())

      _ ->
        handle_with_regular_expression(msg)
    end
  end

  def handle_event(_event), do: :ignore

  def handle_with_regular_expression(msg) do
    case DiscordBot.Adapter.Dice.filter_and_roll_dice(msg.content) do
      result when is_binary(result) ->
        Api.create_message(msg.channel_id, "#{msg.author.username}: #{result}")

      nil ->
        :ignore
    end
  end
end
