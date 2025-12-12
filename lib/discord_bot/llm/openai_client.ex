defmodule DiscordBot.Llm.OpenAIClient do
  require Logger

  alias DiscordBot.Infra.HttpClient

  @endpoint "https://api.openai.com/v1/responses"

  def ask_model(input, opts \\ []) do
    build_body(input, opts)
    |> post_request()
    |> case do
      {:ok, response} ->
        handle_response(response)

      {:error, %Req.TransportError{reason: reason}} ->
        Logger.error("OpenAI API transport error: #{inspect(reason)}")
        {:error, "APIへの接続でエラーが発生しました"}

      {:error, exception} ->
        Logger.error("OpenAI API error: #{inspect(exception)}")
        {:error, "APIエラーが発生しました"}
    end
  end

  defp build_body(input, opts) do
    model = Application.get_env(:discord_bot, __MODULE__) |> Keyword.fetch!(:openai_model)
    body = %{"model" => model, "input" => input}

    Enum.into(opts, body, fn {key, value} ->
      {Atom.to_string(key), value}
    end)
  end

  defp post_request(body) do
    api_token = Application.get_env(:discord_bot, __MODULE__) |> Keyword.fetch!(:openai_api_token)

    header = [
      "Content-Type": "application/json",
      Authorization: "Bearer #{api_token}"
    ]

    HttpClient.post(@endpoint, headers: header, json: body)
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

  defp handle_response(%{status: status, body: body}) do
    Logger.error("OpenAI API error: status=#{status}, body=#{inspect(body)}")
    {:error, "APIエラーが発生しました（ステータス: #{status}）"}
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
