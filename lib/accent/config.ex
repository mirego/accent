defmodule Accent.Config do
  @moduledoc """
  This modules provides various helpers to handle environment variables
  """

  @type value_type :: :string | :integer | :boolean | :uri | :cors
  @type config_type :: String.t() | integer() | boolean() | URI.t() | [String.t()]

  @spec get_env(String.t(), nil | value_type()) :: config_type()
  def get_env(key, type \\ :string) do
    value = System.get_env(key)

    parse_env(value, type)
  end

  @spec get_env!(String.t(), nil | value_type()) :: config_type()
  def get_env!(key, type \\ :string) do
    value = System.fetch_env!(key)

    parse_env(value, type)
  end

  def parse_env(value, :string), do: value
  def parse_env(nil, :integer), do: nil
  def parse_env(value, :integer), do: String.to_integer(value)

  def parse_env(nil, :boolean), do: false
  def parse_env("", :boolean), do: false
  def parse_env(value, :boolean), do: String.downcase(value) in ~w(true 1)

  def parse_env(value, :comma_separated_list) when is_bitstring(value) do
    String.split(value, ",")
  end

  def parse_env(_value, :comma_separated_list), do: []

  def parse_env(nil, :cors), do: nil

  def parse_env(value, :cors) when is_bitstring(value) do
    case String.split(value, ",") do
      [origin] -> origin
      origins -> origins
    end
  end

  def parse_env(nil, :uri), do: nil
  def parse_env("", :uri), do: nil
  def parse_env(value, :uri), do: URI.parse(value)

  @spec get_endpoint_url_config(URI.t() | any()) :: nil | [scheme: String.t(), host: String.t(), port: String.t()]
  def get_endpoint_url_config(%URI{scheme: scheme, host: host, port: port}),
    do: [scheme: scheme, host: host, port: port]

  def get_endpoint_url_config(_invalid), do: nil

  @spec get_uri_part(URI.t() | any(), :scheme | :host | :port) :: String.t() | nil
  def get_uri_part(%URI{scheme: scheme}, :scheme), do: scheme
  def get_uri_part(%URI{host: host}, :host), do: host
  def get_uri_part(%URI{port: port}, :port), do: port
  def get_uri_part(_invalid, _part), do: nil
end
