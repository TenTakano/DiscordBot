defmodule DiscordBot.Llm.OpenAIClient do
  alias DiscordBot.HttpClient

  @chat_model "gpt-4o"
  @chat_endpoint "https://api.openai.com/v1/chat/completions"

  def ask_model(history, opts \\ []) do
    body = %{
      "model" => @chat_model,
      "messages" => history
    }

    body =
      Enum.into(opts, body, fn {key, value} ->
        {Atom.to_string(key), value}
      end)

    request!(@chat_endpoint, body) |> handle_response()
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

  defp handle_response(%{status: 200, body: %{"choices" => [choice], "usage" => usage}}) do
    {
      String.to_existing_atom(choice["finish_reason"]),
      choice["message"],
      usage
    }
  end
end
