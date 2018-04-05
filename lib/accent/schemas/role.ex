defmodule Accent.Role do
  defstruct slug: nil

  @type t :: struct

  @all [
    %{slug: "owner"},
    %{slug: "admin"},
    %{slug: "developer"},
    %{slug: "reviewer"}
  ]

  @doc """
  ## Examples

    iex> Accent.Role.slugs()
    ["owner", "admin", "developer", "reviewer"]
  """
  defmacro slugs, do: Enum.map(@all, &Map.get(&1, :slug))

  @doc """
  ## Examples

    iex> Accent.Role.all()
    [
      %Accent.Role{slug: "owner"},
      %Accent.Role{slug: "admin"},
      %Accent.Role{slug: "developer"},
      %Accent.Role{slug: "reviewer"}
    ]
  """
  def all, do: Enum.map(@all, &struct(__MODULE__, &1))
end
