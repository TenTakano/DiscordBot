ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(DiscordBot.Repo, :manual)

Mox.defmock(DiscordBot.Discord.Random.Mock, for: DiscordBot.Discord.Random.Behaviour)
Application.put_env(:discord_bot, DiscordBot.Discord.Random, module: DiscordBot.Discord.Random.Mock)

Mox.defmock(DiscordBot.Discord.Api.Mock, for: DiscordBot.Discord.Api.Behaviour)
Application.put_env(:discord_bot, DiscordBot.Discord.Api, module: DiscordBot.Discord.Api.Mock)

Mox.defmock(DiscordBot.Infra.HttpClient.Mock, for: DiscordBot.Infra.HttpClient.Behaviour)
Application.put_env(:discord_bot, DiscordBot.Infra.HttpClient, module: DiscordBot.Infra.HttpClient.Mock)
