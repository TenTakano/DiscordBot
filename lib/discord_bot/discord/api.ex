defmodule DiscordBot.Discord.Api.Behaviour do
  @callback(
    create_message(integer(), String.t()) :: {:ok, any},
    {:error, Nostrum.Error.ApiError.t()}
  )
  @callback get_current_user!() :: no_return() | Nostrum.Struct.User.t()

  @callback start_typing!(integer()) :: {:ok}
end

defmodule DiscordBot.Discord.Api.Impl do
  @behaviour DiscordBot.Discord.Api.Behaviour

  @impl DiscordBot.Discord.Api.Behaviour
  def create_message(channel_id, content) do
    Nostrum.Api.Message.create(channel_id, content)
  end

  @impl DiscordBot.Discord.Api.Behaviour
  def get_current_user!() do
    Nostrum.Cache.Me.get()
  end

  @impl DiscordBot.Discord.Api.Behaviour
  def start_typing!(channel_id) do
    Nostrum.Api.Channel.start_typing(channel_id)
  end
end

defmodule DiscordBot.Discord.Api do
  def create_message(channel_id, content), do: api_impl().create_message(channel_id, content)

  def get_current_user!(), do: api_impl().get_current_user!()

  def start_typing!(channel_id), do: api_impl().start_typing!(channel_id)

  defp api_impl() do
    Application.get_env(:discord_bot, __MODULE__) |> Keyword.fetch!(:module)
  end
end
