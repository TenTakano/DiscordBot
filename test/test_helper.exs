ExUnit.start()
# Ecto.Adapters.SQL.Sandbox.mode(DiscordBot.Repo, :manual)

Mox.defmock(DiscordBot.RandomUtil.Mock, for: DiscordBot.RandomUtil.Behaviour)
Application.put_env(:discord_bot, DiscordBot.RandomUtil, DiscordBot.RandomUtil.Mock)
