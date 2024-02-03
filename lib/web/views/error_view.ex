defmodule Accent.ErrorView do
  @moduledoc """
  Render common errors for JSON or HTML format

  ## Examples

    iex> Accent.ErrorView.render("400.json", %{reason: "test"})
    %{error: "Bad request", message: "test"}
    iex> Accent.ErrorView.render("400.json", %{reason: %{complex: "data"}})
    %{error: "Bad request", message: "-"}
    iex> Accent.ErrorView.render("400.json", %{reason: %Ecto.Query.CastError{}})
    %{error: "Bad request", message: "Bad argument type cast"}

    iex> Accent.ErrorView.render("404.json", %{reason: %Phoenix.Router.NoRouteError{}})
    %{error: "Not found", message: "Route not found"}
    iex> Accent.ErrorView.render("404.json", %{reason: %Ecto.NoResultsError{}})
    %{error: "Not found", message: "Resource not found"}
    iex> Accent.ErrorView.render("404.json", %{reason: "test"})
    %{error: "Not found", message: "test"}
    iex> Accent.ErrorView.render("404.json", %{reason: %{complex: "data"}})
    %{error: "Not found", message: "-"}

    iex> Accent.ErrorView.render("500.json", %{})
    %{error: "Internal error", message: "An error occurred, someone as been notified"}

    iex> Accent.ErrorView.render("404.html", %{})
    "Page not found"

    iex> Accent.ErrorView.render("500.html", %{})
    "Server internal error"
    iex> Accent.ErrorView.template_not_found("index.html", %{})
    "Server internal error"
  """

  use Phoenix.View, root: "lib/web/templates"

  def render("400.json", %{reason: reason}) do
    message =
      case reason do
        %Ecto.Query.CastError{} -> "Bad argument type cast"
        error when is_binary(error) -> error
        _ -> "-"
      end

    %{
      error: "Bad request",
      message: message
    }
  end

  def render("404.json", %{reason: reason}) do
    message =
      case reason do
        %Phoenix.Router.NoRouteError{} -> "Route not found"
        %Ecto.NoResultsError{} -> "Resource not found"
        error when is_binary(error) -> error
        _ -> "-"
      end

    %{
      error: "Not found",
      message: message
    }
  end

  def render("500.json", _assigns) do
    %{
      error: "Internal error",
      message: "An error occurred, someone as been notified"
    }
  end

  def render("404.html", _assigns) do
    "Page not found"
  end

  def render("500.html", _assigns) do
    "Server internal error"
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render("500.html", assigns)
  end
end
