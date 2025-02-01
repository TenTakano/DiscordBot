defmodule DiscordBotWeb.Controllers.ValidationSchema do
  defmacro __using__(_opts) do
    quote do
      import DiscordBotWeb.Controllers.ValidationSchema
      Module.register_attribute(__MODULE__, :validation_schema, accumulate: true)
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

  defmacro __before_compile__(env) do
    fields = Module.get_attribute(env.module, :fields) || []

    quote do
      def __fields__, do: unquote(Macro.escape(fields))

      def validate(data) do
        DiscordBotWeb.Controllers.ValidationSchema.Validator.validate(data, __fields__())
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

  def validate(_, _), do: {:error, "Invalid data"}

  defp cast_value(nil, _type), do: {:ok, nil}
  defp cast_value(value, :integer) when is_integer(value), do: {:ok, value}

  defp cast_value(value, :integer) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} -> {:ok, int}
      _ -> {:error, :invalid_integer}
    end
  end

  defp cast_value(value, :string) when is_binary(value), do: {:ok, value}
  defp cast_value(value, :string), do: {:ok, to_string(value)}
  defp cast_value(value, :boolean) when is_boolean(value), do: {:ok, value}

  defp cast_value(value, :boolean) when is_binary(value) do
    case String.downcase(value) do
      "true" -> {:ok, true}
      "false" -> {:ok, false}
      _ -> {:error, :invalid_boolean}
    end
  end

  defp cast_value(_, _), do: {:error, :invalid_type}
end
