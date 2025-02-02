defmodule DiscordBot.Llm.History do
  alias DiscordBot.Llm.Prompts

  def generate_initial_history(message) do
    [
      %{
        "role" => "system",
        "content" => Prompts.system_prompt()
      },
      %{
        "role" => "user",
        "content" => message
      }
    ]
  end

  def append_tool_call(history, tool_call_message) do
    List.insert_at(history, -1, tool_call_message)
  end

  def append_tool_result(history, tool_call_id, tool_result) do
    List.insert_at(history, -1, %{
      "role" => "tool",
      "tool_call_id" => tool_call_id,
      "content" => tool_result
    })
  end
end
