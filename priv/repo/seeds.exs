# Script for populating the database. You can run it as:
#
#     mix run --no-start priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     DiscordBot.Repo.insert!(%DiscordBot.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

{:ok, _} = Application.ensure_all_started(:ecto_sql)

case DiscordBot.Repo.start_link() do
  {:ok, _pid} ->
    :ok

  {:error, {:already_started, _pid}} ->
    :ok

  {:error, reason} ->
    raise "Repo failed to start: #{inspect(reason)}"
end

alias DiscordBot.Repo

tool_function_definitions = [
  {DiscordBot.Adapter.Ip, :get_global_ip,
   %{
     type: "function",
     function: %{
       name: "get_global_ip",
       description: "Get the global IP address of the server.",
       parameters: %{
         type: "object",
         properties: %{},
         required: [],
         additionalProperties: false
       },
       strict: true
     }
   }}
]

Enum.each(tool_function_definitions, fn {mod, fun, definition} ->
  serialized = :erlang.term_to_binary({mod, fun}) |> Base.encode64()

  Repo.insert(
    %DiscordBot.Llm.ToolFunction{
      name: serialized,
      definition: definition
    },
    on_conflict: [set: [definition: definition]],
    conflict_target: [:name]
  )
end)
