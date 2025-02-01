defmodule DiscordBotWeb.LlmController do
  use DiscordBotWeb, :controller

  alias DiscordBot.Llm

  @total_cost_per_million_tokens 10

  def report_monthly_cost(conn, _params) do
    tokens = Llm.get_total_usage()
    usd_cost = Float.ceil(tokens / 1_000_000) * @total_cost_per_million_tokens

    :ok = Llm.reset_total_usage()

    json(conn, %{tokens: tokens, usd_cost: usd_cost})
  end
end
