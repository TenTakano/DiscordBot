import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :discord_bot, DiscordBot.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "discord_bot_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :discord_bot, DiscordBotWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "tJPL5lXCF9SrdI82ugoFVmx69p9WI42IsQADqwbUeOZN6drW+MIvkLQKOFJVM9Yz",
  server: false

# In test we don't send emails
config :discord_bot, DiscordBot.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :discord_bot, DiscordBot.Adapter, start_listener: false

config :discord_bot, DiscordBotWeb.AccountAuth, api_token: "valid_token"
