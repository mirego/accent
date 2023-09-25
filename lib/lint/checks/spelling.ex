defmodule Accent.Lint.Checks.Spelling do
  @moduledoc false
  @behaviour Accent.Lint.Check

  alias Accent.Lint.Message
  alias Accent.Lint.Replacement

  @impl true
  def enabled?, do: not is_nil(base_url())

  @impl true
  def applicable(entry) do
    ((!entry.is_master and entry.value !== entry.master_value) or entry.is_master) and
      String.length(entry.value) < 100 and String.length(entry.value) > 3
  end

  @impl true
  def check(entry) do
    req =
      Req.new(
        base_url: base_url(),
        params: %{text: entry.value, language: build_language_slug(entry.language_slug)}
      )

    matches = Req.get!(req, url: "/v2/check").body["matches"]

    for match <- matches do
      replacement =
        case match["replacements"] do
          [%{"value" => fixed_value} | _] ->
            value =
              String.replace(
                entry.value,
                String.slice(entry.value, match["offset"], match["length"]),
                fixed_value
              )

            %Replacement{value: value, label: fixed_value}

          _ ->
            nil
        end

      %Message{
        check: :spelling,
        text: entry.value,
        offset: match["offset"],
        length: match["length"],
        message: match["message"],
        replacement: replacement
      }
    end
  end

  defp build_language_slug(slug) do
    if String.match?(slug, ~r/..-.*/) do
      slug
    else
      slug <> "-CA"
    end
  end

  defp base_url do
    Application.get_env(:accent, Accent.Lint)[:spelling_server_url]
  end
end
