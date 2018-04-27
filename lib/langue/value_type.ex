defmodule Langue.ValueType do
  def parse(value) when is_boolean(value) or value == "false" or value == "true", do: "boolean"
  def parse(""), do: "empty"
  def parse(value) when value in [:null, "nil"], do: "null"
  def parse(value) when is_integer(value), do: "integer"
  def parse(value) when is_float(value), do: "float"
  def parse(_), do: "string"
end
