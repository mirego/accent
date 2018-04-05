defmodule Accent.ErrorView do
  use Phoenix.View, root: "lib/web/templates"

  def render("400.json", %{reason: reason}) do
    message =
      case reason do
        %Ecto.Query.CastError{} -> "Bad argument type cast"
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
      message: "An error occured, someone as been notified"
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
