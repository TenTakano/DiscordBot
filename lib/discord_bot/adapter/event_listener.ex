defmodule DiscordBot.Adapter.EventListener do
  use Nostrum.Consumer

  alias Nostrum.Api

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    IO.inspect(msg)

    case msg.content do
      "ping!" ->
        Api.create_message(msg.channel_id, "I copy and pasted this code")

      content ->
        case DiscordBot.Adapter.Dice.filter_and_roll_dice(content) do
          total when is_integer(total) ->
            create_dice_roll_message(msg, total)

          nil ->
            :ignore
        end
    end
  end

  def handle_event(_event), do: :ignore

  defp create_dice_roll_message(msg, total) do
    Api.create_message(msg.channel_id, "You rolled a #{total}")
  end
end
