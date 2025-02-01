defmodule DiscordBotWeb.LlmController do
  use DiscordBotWeb, :controller

  alias DiscordBot.Llm

  @total_cost_per_million_tokens 10

  defmodule Request do
    use DiscordBotWeb.Controllers.ValidationSchema

    validation_schema do
      field :reset, :boolean, default: false
      field :send_notification, :boolean, default: false
    end
  end

  def report_total_cost(conn, params) do
    with {:ok, %{reset: reset}} <- Request.validate(params) do
      tokens = Llm.get_total_usage()
      usd_cost = Float.ceil(tokens / 1_000_000) * @total_cost_per_million_tokens

      if reset do
        :ok = Llm.reset_total_usage()
      end

      json(conn, %{tokens: tokens, usd_cost: usd_cost})
    else
      _error ->
        put_status(conn, :bad_request) |> json(%{error: "Invalid parameters"})
    end
  end
end
