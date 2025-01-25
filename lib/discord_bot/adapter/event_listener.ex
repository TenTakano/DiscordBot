defmodule DiscordBot.Adapter.EventListener do
  use Nostrum.Consumer

  alias Nostrum.Api.Message

  @impl Nostrum.Consumer
  def handle_event({:MESSAGE_CREATE, %{author: %{bot: nil}} = msg, _ws_state}) do
    IO.inspect msg
    case msg.content do
      "ping!" ->
        Message.create(msg.channel_id, "pong!")
      _ ->
        :ignore
    end
  end

  def handle_event(event, _ws_state) do
    IO.inspect event
    :ignore
  end
end
