defmodule DiscordBot.Llm.Usage do
  use DiscordBot.Schema

  schema "llm_usages" do
    field :total_tokens, :integer, default: 0

    timestamps(type: :utc_datetime)
  end
end
