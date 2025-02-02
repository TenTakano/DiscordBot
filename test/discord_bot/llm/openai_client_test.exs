defmodule DiscordBot.Llm.OpenAiClientTest do
  use ExUnit.Case, async: true

  import Mox

  alias DiscordBot.HttpClient.Mock
  alias DiscordBot.Llm.OpenAIClient

  setup :verify_on_exit!

  describe "ask_model/2" do
    test "returns response from OpenAI API" do
      expect(Mock, :post!, 1, fn _endpoint, _body ->
        %{
          status: 200,
          body: %{
            "choices" => [%{"finish_reason" => "stop", "message" => "response"}],
            "usage" => %{"total_tokens" => 10}
          }
        }
      end)

      assert OpenAIClient.ask_model([], []) == {:stop, "response", %{"total_tokens" => 10}}
    end
  end
end
