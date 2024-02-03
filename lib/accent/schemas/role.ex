defmodule Accent.Role do
  @moduledoc false
  defstruct slug: nil

  @type t :: struct

  @all [
    %{slug: "owner"},
    %{slug: "admin"},
    %{slug: "developer"},
    %{slug: "reviewer"},
    %{slug: "translator"}
  ]

  @doc """
  ## Examples

    iex> Accent.Role.slugs()
    ["owner", "admin", "developer", "reviewer", "translator"]
  """
  defmacro slugs, do: Enum.map(@all, &Map.get(&1, :slug))

  @doc """
  ## Examples

    iex> Accent.Role.all()
    [
      %Accent.Role{slug: "owner"},
      %Accent.Role{slug: "admin"},
      %Accent.Role{slug: "developer"},
      %Accent.Role{slug: "reviewer"},
      %Accent.Role{slug: "translator"}
    ]
  """
  def all, do: Enum.map(@all, &struct(__MODULE__, &1))
end
