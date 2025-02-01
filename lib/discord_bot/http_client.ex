defmodule DiscordBot.HttpClient.Behaviour do
  @callback post!(String.t(), Keyword.t()) :: Req.Response.t()
end

defmodule DiscordBot.HttpClient.Impl do
  @behaviour DiscordBot.HttpClient.Behaviour

  @impl DiscordBot.HttpClient.Behaviour
  def post!(url, options) do
    Req.post!(url, options)
  end
end

defmodule DiscordBot.HttpClient do
  def post!(url, options \\ []) do
    impl().post!(url, options)
  end

  defp impl() do
    Application.get_env(:discord_bot, __MODULE__) |> Keyword.fetch!(:module)
  end
end
