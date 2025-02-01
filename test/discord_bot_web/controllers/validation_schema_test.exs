defmodule DiscordWeb.Controllers.ValidationSchema.ValidatorTest do
  use ExUnit.Case, async: true

  alias DiscordBotWeb.Controllers.ValidationSchema.Validator

  describe "validate/2" do
    test "returns the data if it is valid" do
      data = %{
        arg1: "value",
        arg2: 3,
        arg3: true
      }

      fields = [
        {:arg1, :string, []},
        {:arg2, :integer, []},
        {:arg3, :boolean, []}
      ]

      assert Validator.validate(data, fields) == {:ok, data}
    end

    test "returns the data with the default values if the keys are missing" do
      data = %{}

      fields = [
        {:arg1, :string, []},
        {:arg2, :integer, [default: 10]},
        {:arg3, :boolean, [default: true]}
      ]

      assert Validator.validate(data, fields) ==
               {:ok, %{arg1: nil, arg2: 10, arg3: true}}
    end

    test "returns the data with the atom keys if the keys are strings" do
      assert Validator.validate(%{"arg" => "value"}, [{:arg, :string, []}]) ==
               {:ok, %{arg: "value"}}
    end

    test "returns the data with the default value if the value is nil" do
      assert Validator.validate(%{}, [{:arg, :string, [default: "default"]}]) ==
               {:ok, %{arg: "default"}}
    end

    test "returns an error if the data contains an invalid value" do
      assert Validator.validate(%{"arg" => "invalid"}, [{:arg, :integer, []}]) ==
               {:error, :invalid_integer}
    end

    test "returns an error if the data is not a map" do
      assert Validator.validate(nil, []) == {:error, :invalid_data}
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

  describe "validate_constraints/3" do
    test "returns :ok if there are no constraints" do
      assert Validator.validate_constraints(:key1, "value", []) == :ok
    end

    test "returns :ok if the value is within the min and max constraints" do
      assert Validator.validate_constraints(:key1, 5, [{:min, 0}]) == :ok
      assert Validator.validate_constraints(:key1, 5, [{:max, 10}]) == :ok
      assert Validator.validate_constraints(:key1, 5, [{:min, 0}, {:max, 10}]) == :ok
    end

    test "returns an error if the value is not within the min and max constraints" do
      assert Validator.validate_constraints(:key1, 5, [{:min, 10}]) ==
               {:error, :min_constraint_violation, :key1}

      assert Validator.validate_constraints(:key1, 5, [{:max, 0}]) ==
               {:error, :max_constraint_violation, :key1}
    end

    test "returns :ok if the value is within the in constraints" do
      assert Validator.validate_constraints(:key1, "value", [{:in, ["value"]}]) == :ok
    end

    test "returns an error if the value is not within the in constraints" do
      assert Validator.validate_constraints(:key1, "value", [{:in, ["invalid"]}]) ==
               {:error, :in_constraint_violation, :key1}
    end

    test "returns :ok if the value is required" do
      assert Validator.validate_constraints(:key1, "value", [{:required, true}]) == :ok
    end

    test "returns an error if the value is not required" do
      assert Validator.validate_constraints(:key1, nil, [{:required, true}]) ==
               {:error, :required_constraint_violation, :key1}
    end

    test "ignores the unknown constraints" do
      assert Validator.validate_constraints(:key1, "value", [{:unknown, true}]) == :ok
    end
  end

  describe "check_required/2" do
    test "returns the data if all required fields are present" do
      data = %{
        arg1: "value",
        arg2: 3,
        arg3: true
      }

      assert Validator.check_required(data, [:arg1, :arg2, :arg3]) == {:ok, data}
    end

    test "returns an error if a required field is missing" do
      data = %{
        arg1: "value",
        arg3: true
      }

      assert Validator.check_required(data, [:arg1, :arg2, :arg3]) ==
               {:error, :missing_required_field, :arg2}
    end

    test "returns an error if a required field is nil" do
      data = %{
        arg1: "value",
        arg2: nil,
        arg3: true
      }

      assert Validator.check_required(data, [:arg1, :arg2, :arg3]) ==
               {:error, :missing_required_field, :arg2}
    end
  end
end
