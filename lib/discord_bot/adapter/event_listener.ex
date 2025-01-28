defmodule DiscordBot.Adapter.EventListener do
  use Nostrum.Consumer

  alias DiscordBot.Adapter.{Api, Dice, Ip}

  def handle_event({:MESSAGE_CREATE, %{author: %{bot: nil}} = msg, _ws_state}) do
    with {:ok, mentioned?, message_body} <- need_evaluate?(msg.content) do
      case {get_message_type(message_body), mentioned?} do
        {:get_global_ip, _} ->
          Api.create_message(msg.channel_id, Ip.get_global_ip())

        {{:roll_dice, result}, _} ->
          Api.create_message(msg.channel_id, generate_dice_roll_message(result, msg))

        {:other, true} ->
          # Need to implement this
          # Api.create_message(
          #   msg.channel_id,
          #   "To Be Implemented. The message will response from LLM"
          # )
          :to_be_implemented

        {:other, false} ->
          :ignore
      end
    end
  end

  def handle_event(_event), do: :ignore

  def need_evaluate?(content) do
    Regex.scan(~r/<@\d+>/, content)
    |> List.flatten()
    |> case do
      [] ->
        {:ok, false, content}

      mentions ->
        if mentioned?(mentions) do
          {:ok, true, extract_message_body(content)}
        else
          :error
        end
    end
  end

  defp mentioned?(mentions) do
    %{id: user_id} = Api.get_current_user!()
    "<@#{user_id}>" in mentions
  end

  defp extract_message_body(content) do
    Regex.replace(~r/<@\d+>/, content, "") |> String.trim()
  end

  def get_message_type("!ip"), do: :get_global_ip

  def get_message_type(message_body) do
    case Dice.capture_dice_roll(message_body) do
      result when is_map(result) ->
        {:roll_dice, result}

      nil ->
        :other
    end
  end

  defp generate_dice_roll_message(capture, msg) do
    count = String.to_integer(capture["count"])
    sides = String.to_integer(capture["sides"])

    result = Dice.roll_dice(count, sides)
    "#{msg.author.username}: (#{count}d#{sides}) -> #{result}"
  end
end
