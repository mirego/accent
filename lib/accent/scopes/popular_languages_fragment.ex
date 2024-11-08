defmodule Accent.Scopes.PopularLanguagesFragment do
  @moduledoc false
  defmacro slugs_to_order_fragment(slugs) do
    whens =
      Enum.map(Enum.with_index(slugs, 1), fn {slug, index} ->
        " WHEN '#{slug}' THEN #{index}"
      end)

    sql =
      IO.iodata_to_binary(
        List.flatten([
          "CASE slug",
          whens,
          " ELSE #{length(slugs) + 1}",
          " END"
        ])
      )

    quote do
      fragment(unquote(sql))
    end
  end
end
