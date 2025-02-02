# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     DiscordBot.Repo.insert!(%DiscordBot.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias DiscordBot.Repo

tool_function_definitions = [
  get_global_ip: %{
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
  }
]

Enum.each(tool_function_definitions, fn {name, definition} ->
  Repo.insert(
    %DiscordBot.Llm.ToolFunction{
      name: Atom.to_string(name),
      definition: definition
    },
    on_conflict: [set: [definition: definition]],
    conflict_target: [:name]
  )
end)
