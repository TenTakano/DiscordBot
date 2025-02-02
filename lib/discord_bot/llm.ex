defmodule DiscordBot.Llm do
  import Ecto.Query

  alias DiscordBot.Repo
  alias DiscordBot.Llm.{OpenAIClient, Prompts, ToolFunction, Usage}

  def chat_with_model(message) do
    history = [
      %{
        "role" => "system",
        "content" => Prompts.system_prompt()
      },
      %{
        "role" => "user",
        "content" => message
      }
    ]

    tools = get_tool_functions() |> Enum.map(& &1.definition)

    case OpenAIClient.ask_model(history, tools: tools) do
      {:stop, message, usage} ->
        upsert_usage(usage["total_tokens"])
        %{content: message["content"], total_tokens: usage["total_tokens"]}

      {:tool_calls, message, usage} ->
        upsert_usage(usage["total_tokens"])

        history =
          history ++
            [
              message,
              %{
                "role" => "tool",
                "tool_call_id" => hd(message["tool_calls"])["id"],
                "content" => "134.7.25.83"
              }
            ]

        {:stop, message, usage} = OpenAIClient.ask_model(history, tools: tools)
        upsert_usage(usage["total_tokens"])
        %{content: message["content"], total_tokens: usage["total_tokens"]}
    end
  end

  def get_total_usage() do
    case Repo.one(from u in Usage, select: u.total_tokens) do
      nil -> 0
      total_tokens -> total_tokens
    end
  end

  def upsert_usage(amount) do
    case Repo.one(from(u in Usage)) do
      nil ->
        Repo.insert!(%Usage{total_tokens: amount})
        amount

      %Usage{} = usage ->
        Repo.update_all(Usage, inc: [total_tokens: amount])
        usage.total_tokens + amount
    end
  end

  def reset_total_usage() do
    {_, nil} = Repo.update_all(Usage, set: [total_tokens: 0])
    :ok
  end

  def create_tool_function!(params) do
    %ToolFunction{}
    |> ToolFunction.changeset(params)
    |> Repo.insert!()
  end

  def get_tool_functions() do
    Repo.all(from tf in ToolFunction, where: tf.is_enabled)
  end
end
