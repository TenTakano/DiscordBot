defmodule DiscordBot.Adapter.Api.Behaviour do
  @callback(
    create_message(integer(), String.t()) :: {:ok, any},
    {:error, Nostrum.Error.ApiError.t()}
  )
  @callback get_current_user!() :: no_return() | Nostrum.Struct.User.t()

  @callback start_typing!(integer()) :: {:ok}
end

defmodule DiscordBot.Adapter.Api.Impl do
  @behaviour DiscordBot.Adapter.Api.Behaviour

  @impl DiscordBot.Adapter.Api.Behaviour
  def create_message(channel_id, content) do
    Nostrum.Api.create_message(channel_id, content)
  end

  @impl DiscordBot.Adapter.Api.Behaviour
  def get_current_user!() do
    Nostrum.Api.get_current_user!()
  end

  @impl DiscordBot.Adapter.Api.Behaviour
  def start_typing!(channel_id) do
    Nostrum.Api.start_typing(channel_id)
  end
end

defmodule DiscordBot.Adapter.Api do
  def create_message(channel_id, content), do: api_impl().create_message(channel_id, content)

  def get_current_user!(), do: api_impl().get_current_user!()

  def start_typing!(channel_id), do: api_impl().start_typing!(channel_id)

  defp api_impl() do
    Application.get_env(:discord_bot, __MODULE__) |> Keyword.fetch!(:module)
  end
end
