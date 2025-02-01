defmodule DiscordBotWeb.Controllers.ValidationSchema do
  defmacro __using__(_opts) do
    quote do
      import DiscordBotWeb.Controllers.ValidationSchema
      Module.register_attribute(__MODULE__, :fields, accumulate: true)
      Module.register_attribute(__MODULE__, :required_fields, accumulate: true)
      @before_compile DiscordBotWeb.Controllers.ValidationSchema
    end
  end

  def validation_schema(do: block) do
    quote do
      unquote(block)
    end
  end

  defmacro field(name, type, opts \\ []) do
    quote do
      @fields {unquote(name), unquote(type), unquote(opts)}
    end
  end

  defmacro required(fields) when is_list(fields) do
    quote do
      @required_fields unquote(fields)
    end
  end

  defmacro __before_compile__(env) do
    fields = Module.get_attribute(env.module, :fields) || []
    required_fields = Module.get_attribute(env.module, :required_fields) || []

    quote do
      def __fields__, do: unquote(Macro.escape(fields))

      def __required_fields__, do: unquote(Macro.escape(required_fields))

      def validate(data) do
        with {:ok, validated} <-
               DiscordBotWeb.Controllers.ValidationSchema.Validator.validate(data, __fields__()) do
          DiscordBotWeb.Controllers.ValidationSchema.Validator.check_required(
            data,
            __required_fields__()
          )
        end
      end
    end
  end
end

defmodule DiscordBotWeb.Controllers.ValidationSchema.Validator do
  def validate(data, fields) when is_map(data) do
    Enum.reduce_while(fields, {:ok, %{}}, fn {name, type, opts}, {:ok, acc} ->
      value = Map.get(data, name) || Map.get(data, Atom.to_string(name))

      value =
        case {value, Keyword.fetch(opts, :default)} do
          {nil, {:ok, default}} -> default
          {v, _} -> v
        end

      with {:ok, casted} <- cast_value(value, type) do
        name = if is_binary(name), do: String.to_existing_atom(name), else: name
        {:cont, {:ok, Map.put(acc, name, casted)}}
      else
        {:error, reason} ->
          {:halt, {:error, reason}}
      end
    end)
  end

  def validate(_, _), do: {:error, :invalid_data}

  def cast_value(nil, _type), do: {:ok, nil}
  def cast_value(value, :integer) when is_integer(value), do: {:ok, value}

  def cast_value(value, :integer) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} -> {:ok, int}
      _ -> {:error, :invalid_integer}
    end
  end

  def cast_value(_value, :integer), do: {:error, :invalid_integer}

  def cast_value(value, :string) when is_binary(value), do: {:ok, value}
  def cast_value(value, :string), do: {:ok, to_string(value)}
  def cast_value(value, :boolean) when is_boolean(value), do: {:ok, value}

  def cast_value(value, :boolean) when is_binary(value) do
    case String.downcase(value) do
      "true" -> {:ok, true}
      "false" -> {:ok, false}
      _ -> {:error, :invalid_boolean}
    end
  end

  def cast_value(_, :boolean), do: {:error, :invalid_boolean}
  def cast_value(_, _), do: {:error, :unexpected_type}

  def validate_constraints(_, _, []), do: :ok

  def validate_constraints(key, value, [{:min, min} | remaining]) when is_number(value) do
    if value >= min do
      validate_constraints(key, value, remaining)
    else
      {:error, :min_constraint_violation, key}
    end
  end

  def validate_constraints(key, value, [{:max, max} | remaining]) when is_number(value) do
    if value <= max do
      validate_constraints(key, value, remaining)
    else
      {:error, :max_constraint_violation, key}
    end
  end

  def validate_constraints(key, value, [{:in, values} | remaining]) do
    if Enum.member?(values, value) do
      validate_constraints(key, value, remaining)
    else
      {:error, :in_constraint_violation, key}
    end
  end

  def validate_constraints(key, value, [{:required, true} | remaining]) do
    if value do
      validate_constraints(key, value, remaining)
    else
      {:error, :required_constraint_violation, key}
    end
  end

  def validate_constraints(key, value, [_ | remaining]),
    do: validate_constraints(key, value, remaining)

  def check_required(data, required_fields) do
    Enum.find_value(required_fields, {:ok, data}, fn field ->
      case Map.fetch(data, field) do
        :error ->
          {:error, :missing_required_field, field}

        {:ok, nil} ->
          {:error, :missing_required_field, field}

        {:ok, _value} ->
          false
      end
    end)
  end
end
