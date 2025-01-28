defmodule DiscordBot.Adapter.Llm do
  @api_endpoint "https://api.openai.com/v1/chat/completions"

  def complete_chat(message) do
    case api_token() do
      nil ->
        "Currently API token is not set. Please set it and restart the app."

      api_token ->
        %{content: content, tokens: _tokens} =
          Req.post!(@api_endpoint,
            body: generate_body(message),
            headers: generate_headers(api_token)
          )
          |> extract_response()

        content
    end
  end

  defp api_token() do
    Application.get_env(:discord_bot, __MODULE__) |> Keyword.fetch!(:openai_api_token)
  end

  defp generate_body(message) do
    Jason.encode!(%{
      "model" => "gpt-4o",
      "messages" => [
        %{
          "role" => "system",
          "content" => "あなたは有能なDiscordBotです。"
        },
        %{
          "role" => "user",
          "content" => message
        }
      ]
    })
  end

  defp generate_headers(api_token) do
    [
      "Content-Type": "application/json",
      Authorization: "Bearer #{api_token}"
    ]
  end

  def extract_response(response) do
    %{
      status: 200,
      body: %{
        "choices" => [
          %{
            "message" => %{"content" => content}
          }
        ],
        "usage" => %{"total_tokens" => tokens}
      }
    } = response

    %{content: content, tokens: tokens}
  end
end
