defmodule DiscordBot.Llm.OpenAiClientTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog
  import Mox

  alias DiscordBot.Infra.HttpClient.Mock
  alias DiscordBot.Llm.OpenAIClient

  setup :verify_on_exit!

  describe "ask_model/2" do
    test "returns message response from OpenAI Responses API" do
      expect(Mock, :post!, 1, fn _endpoint, _body ->
        %{
          status: 200,
          body: %{
            "output" => [
              %{
                "type" => "message",
                "content" => [%{"type" => "text", "text" => "Hello, world!"}]
              }
            ],
            "usage" => %{"total_tokens" => 10}
          }
        }
      end)

      assert OpenAIClient.ask_model([]) ==
               {:stop, %{"content" => "Hello, world!"}, %{"total_tokens" => 10}}
    end

    test "returns tool_calls response when function_call is present" do
      expect(Mock, :post!, 1, fn _endpoint, _body ->
        %{
          status: 200,
          body: %{
            "output" => [
              %{
                "type" => "function_call",
                "call_id" => "call_abc123",
                "name" => "get_weather",
                "arguments" => ~s({"location": "Tokyo"})
              }
            ],
            "usage" => %{"total_tokens" => 15}
          }
        }
      end)

      assert OpenAIClient.ask_model([]) ==
               {:tool_calls,
                %{
                  "tool_calls" => [
                    %{
                      "id" => "call_abc123",
                      "function" => %{
                        "name" => "get_weather",
                        "arguments" => ~s({"location": "Tokyo"})
                      }
                    }
                  ]
                }, %{"total_tokens" => 15}}
    end

    test "passes tools option to the API" do
      tool_definitions = [%{"type" => "function", "name" => "test_tool"}]

      expect(Mock, :post!, 1, fn _endpoint, body ->
        assert {:ok, json} = Keyword.fetch(body, :json)
        assert json["tools"] == tool_definitions

        %{
          status: 200,
          body: %{
            "output" => [
              %{"type" => "message", "content" => [%{"type" => "text", "text" => "response"}]}
            ],
            "usage" => %{"total_tokens" => 10}
          }
        }
      end)

      assert {:stop, _, _} = OpenAIClient.ask_model([], tools: tool_definitions)
    end

    test "returns error tuple on rate limit error" do
      expect(Mock, :post!, 1, fn _endpoint, _body ->
        %{
          status: 429,
          body: %{
            "error" => %{
              "message" => "Rate limit reached for default-gpt-4o in organization",
              "type" => "rate_limit_error"
            }
          }
        }
      end)

      log =
        capture_log(fn ->
          assert {:error, "APIエラーが発生しました（ステータス: 429）"} = OpenAIClient.ask_model([])
        end)

      assert log =~ "OpenAI API error: status=429"
    end
  end
end
