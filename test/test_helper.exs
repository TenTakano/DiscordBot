ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(DiscordBot.Repo, :manual)

Mox.defmock(DiscordBot.RandomUtil.Mock, for: DiscordBot.RandomUtil.Behaviour)
Application.put_env(:discord_bot, DiscordBot.RandomUtil, DiscordBot.RandomUtil.Mock)

Mox.defmock(DiscordBot.Adapter.Api.Mock, for: DiscordBot.Adapter.Api.Behaviour)
Application.put_env(:discord_bot, DiscordBot.Adapter.Api, DiscordBot.Adapter.Api.Mock)
