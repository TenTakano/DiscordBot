# DiscordBot

身内のDiscordサーバー向けに開発・運用しているBotです。ご自由に利用・改変していただいて構いませんが、その際は自己責任でお願いします。
Botには以下のような機能があります。

- OpenAI APIを利用した自然な会話機能（Botへのメンションのみに反応）
  - OpenAI APIの利用にはAPIキーが必要です
- ダイスロール機能
  - 「5d6」のようにダイスロールメッセージとして解釈できるメッセージにダイスロールをして回答
  - メンションには反応しません
- 外部APIを利用したグローバルIPアドレス取得機能
  - マイクラサーバーのIPアドレス取得などにどうぞ
  - 会話機能からの呼び出しも可能です

## インストール

### Dockerfileを利用する場合

このリポジトリをdockerが利用できる環境にクローンして以下のコマンドを実行・起動してください。
各環境変数の詳細は後述します。

```bash
$ docker build -t discord_bot .
$ docker run -e DISCORD_BOT_TOKEN={discord botのTOKEN} -e OPEN_API_TOKEN={Open APIのトークン} -e SECRET_KEY_BASE={事前に生成したシークレットキー} -d discord_bot
```

### elixir/phoenixの環境を利用する場合

.tool_versionsに記載されているバージョンのErlang/Elixirをインストールして、[Phoenixフレームワークのリリース方法](https://hexdocs.pm/phoenix/releases.html)にしたがってリリース・起動をしてください。
(開発時はasdfコマンドを利用して環境構築・動作確認を行っています。直接のインストールについては動作未検証です)

リリースを行わず、 `iex -S mix phx.server` で起動することもできます。

## 実行時の環境変数

- 必須
  - DISCORD_BOT_TOKEN
    - Discord Botに接続するために必要です。Developer Portalから取得してください。
  - SECRET_KEY_BASE
    - Phoenixのセッション管理に利用します。予め作成しておく必要があります。任意の文字列でも動作することができますが、セキュリティの観点からランダムな文字列を利用が推奨されます。
    - 作成方法
      - Base64エンコードされたランダムな文字列(長さ: 64文字)を生成してください。
      - Elixir/Phoenixの環境構築ができている場合は `mix phx.gen.secret` で生成することができます。
- 任意
  - OPEN_API_TOKEN
    - メンションを利用した会話機能を利用する場合には必須
    - OpenAI APIのトークンです。OpenAIのサイトから取得してください。
