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

  describe "cast_value/2" do
    test "casts an integer" do
      assert Validator.cast_value(10, :integer) == {:ok, 10}
      assert Validator.cast_value("10", :integer) == {:ok, 10}
    end

    test "casts a string" do
      assert Validator.cast_value("value", :string) == {:ok, "value"}
    end

    test "casts a boolean" do
      assert Validator.cast_value("true", :boolean) == {:ok, true}
      assert Validator.cast_value("false", :boolean) == {:ok, false}
      assert Validator.cast_value(true, :boolean) == {:ok, true}
      assert Validator.cast_value(false, :boolean) == {:ok, false}
    end

    test "returns an error if the value is not a valid integer" do
      assert Validator.cast_value("invalid", :integer) == {:error, :invalid_integer}
      assert Validator.cast_value(10.0, :integer) == {:error, :invalid_integer}
    end

    test "returns an error if the value is not a valid boolean" do
      assert Validator.cast_value("invalid", :boolean) == {:error, :invalid_boolean}
      assert Validator.cast_value(10, :boolean) == {:error, :invalid_boolean}
    end

    test "returns an error if the type is invalid" do
      assert Validator.cast_value("value", :invalid) == {:error, :unexpected_type}
    end
  end
end
