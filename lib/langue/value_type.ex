defmodule Langue.ValueType do
  @moduledoc false
  def parse(value) when is_boolean(value) or value in ["false", "true"], do: "boolean"
  def parse(""), do: "empty"
  def parse(value) when value in [:null, "nil"], do: "null"
  def parse(value) when is_integer(value), do: "integer"
  def parse(value) when is_float(value), do: "float"
  def parse(_), do: "string"
end
