defmodule DiscordBot.Llm.ToolFunction do
  use DiscordBot.Schema

  schema "tool_functions" do
    field :name, :string
    field :definition, :string
    field :is_enabled, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  def changeset(llm_function, attrs) do
    llm_function
    |> cast(attrs, [:name, :is_enabled])
    |> cast_definition(attrs)
    |> validate_required([:name, :definition])
    |> unique_constraint(:name)
  end

  def cast_definition(changeset, attrs) do
    definition = Map.get(attrs, :definition) || Map.get(attrs, "definition")

    if is_map(definition) do
      put_change(changeset, :definition, Jason.encode!(definition))
    else
      changeset
    end
  end
end
