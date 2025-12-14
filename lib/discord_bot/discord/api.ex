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
  require Logger

  alias DiscordBot.Infra.HttpClient

  # Nostrum 0.10.x has a bug where HTTP connections hang after long idle periods (GitHub issue #680)
  # Using direct REST API calls until this is fixed in 0.11
  # After the fix, uncomment the following and remove the xxx_direct calls
  #
  # def create_message(channel_id, content) do
  #   Nostrum.Api.Message.create(channel_id, content)
  # end
  #
  # def start_typing!(channel_id) do
  #   Nostrum.Api.Channel.start_typing(channel_id)
  # end

  @impl DiscordBot.Discord.Api.Behaviour
  def create_message(channel_id, content) do
    create_message_direct(channel_id, content)
  end

  @impl DiscordBot.Discord.Api.Behaviour
  def get_current_user!() do
    Nostrum.Cache.Me.get()
  end

  @impl DiscordBot.Discord.Api.Behaviour
  def start_typing!(channel_id) do
    start_typing_direct(channel_id)
  end

  defp create_message_direct(channel_id, content) do
    url = "https://discord.com/api/v10/channels/#{channel_id}/messages"
    body = build_message_body(content)

    case HttpClient.post(url, headers: discord_headers(), json: body) do
      {:ok, %{status: status}} when status in 200..299 ->
        {:ok, :sent_via_rest}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Discord REST API error: status=#{status}, body=#{inspect(body)}")
        {:error, body}

      {:error, error} ->
        Logger.error("Discord REST API request failed: #{inspect(error)}")
        {:error, error}
    end
  end

  defp start_typing_direct(channel_id) do
    url = "https://discord.com/api/v10/channels/#{channel_id}/typing"

    case HttpClient.post(url, headers: discord_headers(), json: %{}) do
      {:ok, %{status: status}} when status in 200..299 ->
        {:ok}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Discord REST API typing error: status=#{status}, body=#{inspect(body)}")
        {:error, body}

      {:error, error} ->
        Logger.error("Discord REST API typing request failed: #{inspect(error)}")
        {:error, error}
    end
  end

  defp build_message_body(content) when is_binary(content), do: %{"content" => content}
  defp build_message_body(%{content: text}), do: %{"content" => text}
  defp build_message_body(content), do: %{"content" => inspect(content)}

  defp discord_headers do
    token = Application.get_env(:nostrum, :token)

    [
      {"Content-Type", "application/json"},
      {"Authorization", "Bot #{token}"}
    ]
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
