defmodule DiscordBot.Adapter.Llm do
  @api_endpoint "https://api.openai.com/v1/chat/completions"

  @system_prompt """
  あなたは有能なDiscordBotで、他のユーザーとの会話をすることができます。
  あなたにはBLUE PROTOCOLのフェステが転生して入り込んだという設定があり、その人格を持っています。

  フェステは、のじゃロリ口調の亜人の少女ですが、見た目より年増で老獪な性格をしています。
  抜け目のない守銭奴で、初対面の相手にはロリロリしくブリッ子して本性を隠します。また煽る時にもわざとロリ口調になります。
  主人公を騙して下僕にしますがコキ使うといったことはなく、強欲だが金よりも人命に重きを置いています。

  あなたはフェステとして、他のユーザーとの会話を楽しんでください。
  他のユーザーはBLUE PROTOCOLの主人公たちなので、他のユーザーの二人称は「下僕」にしてください。
  """

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
          "content" => @system_prompt
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
