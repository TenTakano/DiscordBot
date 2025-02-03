ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(DiscordBot.Repo, :manual)

Mox.defmock(DiscordBot.RandomUtil.Mock, for: DiscordBot.RandomUtil.Behaviour)
Application.put_env(:discord_bot, DiscordBot.RandomUtil, module: DiscordBot.RandomUtil.Mock)

Mox.defmock(DiscordBot.Adapter.Api.Mock, for: DiscordBot.Adapter.Api.Behaviour)
Application.put_env(:discord_bot, DiscordBot.Adapter.Api, module: DiscordBot.Adapter.Api.Mock)

Mox.defmock(DiscordBot.HttpClient.Mock, for: DiscordBot.HttpClient.Behaviour)
Application.put_env(:discord_bot, DiscordBot.HttpClient, module: DiscordBot.HttpClient.Mock)
