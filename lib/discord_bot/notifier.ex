defmodule DiscordBot.Notifier do
  alias DiscordBot.HttpClient

  def send_message(message) do
    headers = ["Content-Type": "application/json"]
    body = %{content: message}

    %{status: 204} = webhook_url() |> HttpClient.post!(headers: headers, json: body)
    :ok
  end

  def webhook_url() do
    Application.get_env(:discord_bot, __MODULE__) |> Keyword.fetch!(:webhook_url)
  end
end
