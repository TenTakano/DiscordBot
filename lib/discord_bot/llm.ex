defmodule DiscordBot.Llm do
  import Ecto.Query

  alias DiscordBot.Repo
  alias DiscordBot.Llm.{History, OpenAIClient, ToolFunction, Usage}

  def chat_with_model(message) do
    history = History.generate_initial_history(message)
    tools = get_tool_functions() |> Enum.map(& &1.definition)

    chat_with_model_repeatedly(history, tools)
  end

  defp chat_with_model_repeatedly(history, tools) do
    {reason, message, usage} = OpenAIClient.ask_model(history, tools: tools)
    upsert_usage(usage["total_tokens"])

    case {reason, message} do
      {:stop, message} ->
        %{content: message["content"], total_tokens: usage["total_tokens"]}

      {:tool_calls, message} ->
        history =
          Enum.reduce(
            message["tool_calls"],
            History.append_tool_call(history, message),
            &execute_tool_function/2
          )

        chat_with_model_repeatedly(history, tools)
    end
  end

  defp execute_tool_function(tool_call, history) do
    tool_result = "134.7.25.83"
    History.append_tool_result(history, tool_call["id"], tool_result)
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
