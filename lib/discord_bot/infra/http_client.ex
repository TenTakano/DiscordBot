defmodule DiscordBot.Infra.HttpClient.Behaviour do
  @callback post(String.t(), Keyword.t()) :: {:ok, Req.Response.t()} | {:error, Exception.t()}
  @callback post!(String.t(), Keyword.t()) :: Req.Response.t()
end

defmodule DiscordBot.Infra.HttpClient.Impl do
  @behaviour DiscordBot.Infra.HttpClient.Behaviour

  defp default_options do
    [
      pool_timeout: 5_000,
      receive_timeout: 60_000,
      retry: :transient,
      retry_delay: &(&1 * 1_000),
      max_retries: 2
    ]
  end

  @impl DiscordBot.Infra.HttpClient.Behaviour
  def post(url, options) do
    Req.post(url, Keyword.merge(default_options(), options))
  end

  @impl DiscordBot.Infra.HttpClient.Behaviour
  def post!(url, options) do
    Req.post!(url, Keyword.merge(default_options(), options))
  end
end

defmodule DiscordBot.Infra.HttpClient do
  def post(url, options \\ []) do
    impl().post(url, options)
  end

  def post!(url, options \\ []) do
    impl().post!(url, options)
  end

  defp impl() do
    Application.get_env(:discord_bot, __MODULE__) |> Keyword.fetch!(:module)
  end
end
