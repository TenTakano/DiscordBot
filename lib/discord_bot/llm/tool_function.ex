defmodule DiscordBot.Llm.ToolFunction do
  use DiscordBot.Schema

  schema "tool_functions" do
    field :name, :string
    field :definition, :map
    field :is_enabled, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  def changeset(llm_function, attrs) do
    llm_function
    |> cast(attrs, [:name, :definition, :is_enabled])
    |> validate_required([:name, :definition])
    |> unique_constraint(:name)
  end
end
