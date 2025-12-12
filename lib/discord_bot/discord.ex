defmodule DiscordBot.Discord do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl Supervisor
  def init(_init_arg) do
    children = if start_listener(), do: [DiscordBot.Discord.EventListener], else: []

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp start_listener() do
    Application.get_env(:discord_bot, __MODULE__) |> Keyword.fetch!(:start_listener)
  end
end
