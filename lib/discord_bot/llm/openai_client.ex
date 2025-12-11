defmodule DiscordBot.Llm.OpenAIClient do
  alias DiscordBot.HttpClient

  @model "gpt-4.1"
  @endpoint "https://api.openai.com/v1/responses"

  def ask_model(input, opts \\ []) do
    body = %{"model" => @model, "input" => input}

    body =
      Enum.into(opts, body, fn {key, value} ->
        {Atom.to_string(key), value}
      end)

    request!(@endpoint, body) |> handle_response()
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

  defp handle_response(%{status: 200, body: body}) do
    output = body["output"]
    usage = body["usage"]

    case extract_result(output) do
      {:message, text} ->
        {:stop, %{"content" => text}, usage}

      {:function_calls, calls} ->
        {:tool_calls, %{"tool_calls" => calls}, usage}
    end
  end

  defp extract_result(output) do
    function_calls =
      output
      |> Enum.filter(&(&1["type"] == "function_call"))
      |> Enum.map(fn call ->
        %{
          "id" => call["call_id"],
          "function" => %{
            "name" => call["name"],
            "arguments" => call["arguments"]
          }
        }
      end)

    if Enum.empty?(function_calls) do
      message = Enum.find(output, &(&1["type"] == "message"))
      text = get_in(message, ["content", Access.at(0), "text"]) || ""
      {:message, text}
    else
      {:function_calls, function_calls}
    end
  end
end
