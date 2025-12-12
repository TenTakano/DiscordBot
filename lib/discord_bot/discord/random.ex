defmodule DiscordBot.Discord.Random.Behaviour do
  @callback random(integer()) :: integer()
end

defmodule DiscordBot.Discord.Random.Impl do
  @behaviour DiscordBot.Discord.Random.Behaviour

  @impl DiscordBot.Discord.Random.Behaviour
  def random(max) do
    :rand.uniform(max)
  end
end

defmodule DiscordBot.Discord.Random do
  def random(max), do: random_impl().random(max)

  defp random_impl() do
    Application.get_env(:discord_bot, __MODULE__) |> Keyword.fetch!(:module)
  end
end
