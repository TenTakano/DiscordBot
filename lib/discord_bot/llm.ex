defmodule DiscordBot.Llm do
  import Ecto.Query

  alias DiscordBot.Repo
  alias DiscordBot.Llm.{History, OpenAIClient, ToolFunction, Usage}

  def chat_with_model(message) do
    input = History.generate_initial_input(message)
    tools = get_tool_functions()

    chat_with_model_repeatedly(input, tools)
  end

  defp chat_with_model_repeatedly(input, tools) do
    tool_definitions = Enum.map(tools, & &1.definition)

    opts = [
      instructions: History.instructions(),
      tools: tool_definitions
    ]

    {reason, message, usage} = OpenAIClient.ask_model(input, opts)
    upsert_usage(usage["total_tokens"])

    case {reason, message} do
      {:stop, message} ->
        %{content: message["content"], total_tokens: usage["total_tokens"]}

      {:tool_calls, message} ->
        input =
          Enum.reduce(
            message["tool_calls"],
            History.append_tool_call(input, message["tool_calls"]),
            &execute_tool_function(&1, &2, tools)
          )

        chat_with_model_repeatedly(input, tools)
    end
  end

  # TODO: Need to update for using arguments
  defp execute_tool_function(tool_call, history, tools) do
    %{name: serialized} =
      Enum.find(tools, fn %{definition: definition} ->
        definition["function"]["name"] == tool_call["function"]["name"]
      end)

    {mod, fun} = Base.decode64!(serialized) |> :erlang.binary_to_term()
    result = apply(mod, fun, [])
    History.append_tool_result(history, tool_call["id"], result)
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
