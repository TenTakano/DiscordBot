defmodule DiscordBot.RandomUtil.Behaviour do
  @callback random(integer()) :: integer()
end

defmodule DiscordBot.RandomUtil.Impl do
  @behaviour DiscordBot.RandomUtil.Behaviour

  @impl DiscordBot.RandomUtil.Behaviour
  def random(max) do
    :rand.uniform(max)
  end
end

defmodule DiscordBot.RandomUtil do
  def random(max), do: random_impl().random(max)

  defp random_impl() do
    Application.get_env(:discord_bot, __MODULE__) |> Keyword.fetch!(:module)
  end
end
