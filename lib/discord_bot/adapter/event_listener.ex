defmodule DiscordBot.Adapter.EventListener do
  use Nostrum.Consumer

  alias Nostrum.Api

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "ping!" ->
        Api.create_message(msg.channel_id, "I copy and pasted this code")

      content ->
        case DiscordBot.Adapter.Dice.filter_and_roll_dice(content) do
          result when is_binary(result) ->
            Api.create_message(msg.channel_id, "#{msg.author.username}: #{result}")

          nil ->
            :ignore
        end
    end
  end

  def handle_event(_event), do: :ignore
end
