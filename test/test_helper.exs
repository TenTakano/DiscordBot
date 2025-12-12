ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(DiscordBot.Repo, :manual)

Mox.defmock(DiscordBot.RandomUtil.Mock, for: DiscordBot.RandomUtil.Behaviour)
Application.put_env(:discord_bot, DiscordBot.RandomUtil, module: DiscordBot.RandomUtil.Mock)

Mox.defmock(DiscordBot.Discord.Api.Mock, for: DiscordBot.Discord.Api.Behaviour)
Application.put_env(:discord_bot, DiscordBot.Discord.Api, module: DiscordBot.Discord.Api.Mock)

Mox.defmock(DiscordBot.HttpClient.Mock, for: DiscordBot.HttpClient.Behaviour)
Application.put_env(:discord_bot, DiscordBot.HttpClient, module: DiscordBot.HttpClient.Mock)
