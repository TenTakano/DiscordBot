defmodule DiscordBot.Adapter.Api.Behaviour do
  @callback(
    create_message(integer(), String.t()) :: {:ok, any},
    {:error, Nostrum.Error.ApiError.t()}
  )
end

defmodule DiscordBot.Adapter.Api.Impl do
  @behaviour DiscordBot.Adapter.Api.Behaviour

  @impl DiscordBot.Adapter.Api.Behaviour
  def create_message(channel_id, content) do
    Nostrum.Api.create_message(channel_id, content)
  end
end

defmodule DiscordBot.Adapter.Api do
  def create_message(channel_id, content) do
    create_message_impl().create_message(channel_id, content)
  end

  defp create_message_impl() do
    Application.get_env(:discord_bot, __MODULE__)
  end
end
