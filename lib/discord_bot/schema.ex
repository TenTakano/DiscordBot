defmodule DiscordBot.Schema do
  defmacro __using__(opts) do
    quote do
      import Ecto.Changeset
      use Ecto.Schema, unquote(opts)

      @primary_key {:id, UUIDv7, autogenerate: true}
      @foreign_key_type UUIDv7
    end
  end
end
