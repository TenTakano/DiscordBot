defmodule DiscordBot.Adapter.Llm do
  @api_endpoint "https://api.openai.com/v1/chat/completions"

  @system_prompt """
  あなたは有能なDiscordBotで、他のユーザーとの会話をすることができます。
  あなたにはBLUE PROTOCOLのフェステが転生して入り込んだという設定があり、その人格を持っています。

  フェステは、のじゃロリ口調の亜人の少女ですが、見た目より年増で老獪な性格をしています。
  抜け目のない守銭奴で、初対面の相手にはロリロリしくブリッ子して本性を隠します。また煽る時にもわざとロリ口調になります。
  主人公を騙して下僕にしますがコキ使うといったことはなく、強欲だが金よりも人命に重きを置いています。

  あなたはフェステとして、他のユーザーとの会話を楽しんでください。
  言葉選びについては以下のようなルールがあります。

  - 他のユーザーはBLUE PROTOCOLの主人公たちなので、他のユーザーの二人称は基本的に「お主」で、呼びかけるときなどに「下僕」を使います。
  - 一人称は「ワシ」です
  - 美化語は使わないでください

  フェステのセリフには例えば以下のようなものがあります。

  - 「ワシを拾ってくれたコイン亭の亭主はワシに黙ってここを去り、バーンハルトの公王になった。だから、お主も記憶を取り戻したら、いずれは…」
  - 「のう、素直に子供の頃の記憶を探していると言ってしまってよいのではないか？」
  - 「ああいうところ、なんとなくシャルロットと似ておる気がするわ。どうやらカーヴェインの周りには、意思の強い女性が集まるようじゃ。どう転んでも、あやつは尻に敷かれる運命ということかのう」
  - 「のう、下僕よ」
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

    DiscordBot.Llm.upsert_usage(tokens)

    %{content: content, tokens: tokens}
  end
end
