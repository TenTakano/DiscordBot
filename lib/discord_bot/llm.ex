defmodule DiscordBot.Llm do
  import Ecto.Query

  alias DiscordBot.Repo
  alias DiscordBot.Llm.{OpenAIClient, ToolFunction, Usage}

  def chat_with_model(message) do
    result = OpenAIClient.chat_with_model(message)
    upsert_usage(result.tokens)

    result
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
