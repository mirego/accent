defmodule Accent.GraphQL.Response do
  alias AbsintheErrorPayload.ValidationMessage

  @type t :: {:ok, nil | map() | list() | {:error, String.t()}}

  @doc """
  Error tuple returned by Ecto or other services should not be treated as GraphQL errors,
  they are simply returned as a changeset or validation messages and taken care of by AbsintheErrorPayload.

  ## Examples
      iex> build({:ok, "a record"})
      {:ok, "a record"}
      iex> build({:error, %Ecto.Changeset{data: "some data"}})
      {:ok, %Ecto.Changeset{data: "some data"}}
      iex> build({:error, %AbsintheErrorPayload.ValidationMessage{code: "an error"}})
      {:ok, %AbsintheErrorPayload.ValidationMessage{code: "an error"}}
      iex>build({:error, %{field: "field", code: "an error"}})
      {:ok, %AbsintheErrorPayload.ValidationMessage{field: "field", code: "an error"}}
      iex> build({:error, "an error"})
      {:ok, %AbsintheErrorPayload.ValidationMessage{code: "an error"}}
      iex> build(%{data: "a record"})
      {:ok, %{data: "a record"}}
      iex> build(["a record", "another record"])
      {:ok, ["a record", "another record"]}
      iex> build(nil)
      {:ok, nil}
      iex> build("anything")
      {:ok, {:error, "internal server error"}}
  """
  def build(nil), do: {:ok, nil}

  def build({:ok, record}), do: {:ok, record}
  def build(boolean) when is_boolean(boolean), do: {:ok, boolean}
  def build(record) when is_map(record), do: {:ok, record}
  def build(records) when is_list(records), do: {:ok, records}

  def build({:error, %Ecto.Changeset{} = changeset}), do: {:ok, changeset}

  def build({:error, %ValidationMessage{} = error}), do: {:ok, error}

  def build({:error, %{field: field, code: code}}),
    do: {:ok, %ValidationMessage{field: field, code: code}}

  def build({:error, %{code: code, message: message}}),
    do: {:ok, %ValidationMessage{code: code, message: message}}

  def build({:error, error}) when is_binary(error),
    do: {:ok, %ValidationMessage{code: error}}

  def build(_), do: {:ok, {:error, "internal server error"}}
end
