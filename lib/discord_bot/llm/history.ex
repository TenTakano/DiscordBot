defmodule DiscordBot.Llm.History do
  alias DiscordBot.Llm.Prompts

  def generate_initial_input(message) do
    [
      %{
        "role" => "user",
        "content" => message
      }
    ]
  end

  def instructions do
    Prompts.system_prompt()
  end

  def append_tool_call(input, tool_calls) do
    function_calls =
      Enum.map(tool_calls, fn call ->
        %{
          "type" => "function_call",
          "call_id" => call["id"],
          "name" => call["function"]["name"],
          "arguments" => call["function"]["arguments"]
        }
      end)

    input ++ function_calls
  end

  def append_tool_result(input, tool_call_id, tool_result) do
    input ++
      [
        %{
          "type" => "function_call_output",
          "call_id" => tool_call_id,
          "output" => tool_result
        }
      ]
  end
end
