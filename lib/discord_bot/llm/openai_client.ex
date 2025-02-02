defmodule DiscordBot.Llm.OpenAIClient do
  alias DiscordBot.HttpClient
  alias DiscordBot.Llm.Prompts

  @chat_model "gpt-4o"
  @chat_endpoint "https://api.openai.com/v1/chat/completions"

  def chat_with_model(message) do
    body = %{
      "model" => @chat_model,
      "messages" => [
        %{
          "role" => "system",
          "content" => Prompts.system_prompt()
        },
        %{
          "role" => "user",
          "content" => message
        }
      ]
    }

    request!(@chat_endpoint, body) |> extract_response()
  end

  defp request!(url, body) do
    HttpClient.post!(url, headers: headers(), json: body)
  end

  defp headers() do
    [
      "Content-Type": "application/json",
      Authorization: "Bearer #{api_token()}"
    ]
  end

  defp api_token() do
    Application.get_env(:discord_bot, __MODULE__) |> Keyword.fetch!(:openai_api_token)
  end

  defp extract_response(%{status: 200, body: body}) do
    %{
      "choices" => [%{"message" => %{"content" => content}}],
      "usage" => %{"total_tokens" => tokens}
    } = body

    %{content: content, tokens: tokens}
  end
end
