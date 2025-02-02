defmodule DiscordBot.LlmTest do
  use DiscordBot.DataCase, async: true

  alias DiscordBot.Llm

  describe "upsert_usage/1" do
    test "creates a new usage record if none exists" do
      assert Llm.upsert_usage(10) == 10
      assert Llm.get_total_usage() == 10
    end

    test "increments the total tokens if a usage record exists" do
      Llm.upsert_usage(10)

      assert Llm.upsert_usage(10) == 20
      assert Llm.get_total_usage() == 20
    end
  end

  describe "reset_total_usage/0" do
    test "resets the total tokens to 0" do
      Llm.upsert_usage(10)

      assert Llm.reset_total_usage() == :ok
      assert Llm.get_total_usage() == 0
    end
  end

  describe "create_tool_function!/1" do
    test "creates a new tool function" do
      tool_function =
        Llm.create_tool_function!(%{
          name: "test",
          definition: %{key: "value"}
        })

      assert tool_function.name == "test"
      assert tool_function.definition == %{key: "value"}
      assert tool_function.is_enabled == true
    end

    test "raises an error if the name is not unique" do
      Llm.create_tool_function!(%{
        name: "test",
        definition: %{key: "value"}
      })

      assert_raise Ecto.InvalidChangesetError, fn ->
        Llm.create_tool_function!(%{
          name: "test",
          definition: %{key: "value"}
        })
      end
    end

    test "raises an error if the description is invalid JSON" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Llm.create_tool_function!(%{
          name: "test",
          definition: "invalid"
        })
      end
    end
  end

  describe "get_tool_functions/0" do
    test "returns tool functions whose is_enabled is true" do
      tool_function =
        Llm.create_tool_function!(%{
          name: "test",
          definition: %{"key" => "value"}
        })

      Llm.create_tool_function!(%{
        name: "test2",
        definition: %{key: "value"},
        is_enabled: false
      })

      assert Llm.get_tool_functions() == [tool_function]
    end
  end
end
