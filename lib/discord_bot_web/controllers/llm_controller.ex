defmodule DiscordBotWeb.LlmController do
  use DiscordBotWeb, :controller

  alias DiscordBot.Llm

  @total_cost_per_million_tokens 10

  def report_total_cost(conn, params) do
    with {:ok, %{reset: reset}} <- validate_params(params) do
      tokens = Llm.get_total_usage()
      usd_cost = Float.ceil(tokens / 1_000_000) * @total_cost_per_million_tokens

      if reset do
        :ok = Llm.reset_total_usage()
      end

      json(conn, %{tokens: tokens, usd_cost: usd_cost})
    else
      {:error, :bad_request} ->
        put_status(conn, :bad_request) |> json(%{error: "Invalid parameters"})
    end
  end

  defp validate_params(%{"reset" => reset}) when is_boolean(reset), do: {:ok, %{reset: reset}}
  defp validate_params(%{"reset" => _reset}), do: {:error, :bad_request}
  defp validate_params(_params), do: {:ok, %{reset: false}}
end
