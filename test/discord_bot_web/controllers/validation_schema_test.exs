defmodule DiscordWeb.Controllers.ValidationSchema.ValidatorTest do
  use ExUnit.Case, async: true

  alias DiscordBotWeb.Controllers.ValidationSchema.Validator

  describe "validate/2" do
    test "returns the data if it is valid" do
      Enum.each(
        [
          %{arg: "value"},
          %{"arg" => "value"}
        ],
        fn data ->
          assert Validator.validate(data, [{:arg, :string, []}]) == {:ok, %{arg: "value"}}
        end
      )
    end

    test "returns the data with the default value if the value is nil" do
      assert {:ok, %{arg: "default"}} =
               Validator.validate(%{}, [{:arg, :string, [default: "default"]}])
    end

    test "returns an error if the data contains an invalid value" do
      assert {:error, :invalid_integer} =
               Validator.validate(%{"arg" => "invalid"}, [{:arg, :integer, []}])
    end

    test "returns an error if the data is not a map" do
      assert {:error, "Invalid data"} = Validator.validate(nil, [])
    end
  end
end
