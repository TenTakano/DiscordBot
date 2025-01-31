defmodule DiscordBot.Llm do
  import Ecto.Query

  alias DiscordBot.Repo
  alias DiscordBot.Llm.Usage

  def get_total_usage(), do: Repo.one(from u in Usage, select: u.total_tokens)

  def upsert_usage(amount) do
    case Repo.one(from(u in Usage)) do
      nil ->
        Repo.insert!(%Usage{total_tokens: amount})
        amount

      %Usage{} = usage ->
        Repo.update_all(Usage, inc: [total_tokens: amount])
        usage.total_tokens + amount
    end
  end
end
