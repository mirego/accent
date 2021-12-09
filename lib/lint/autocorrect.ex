defmodule Accent.Lint.Autocorrect do
  @provider %{
    generate_messages: fn _ -> {:ok, []} end
  }

  def autocorrect(entry) do
    entry
    |> @provider.generate_messages()
    |> case do
      {:ok, messages} ->
        %{entry | messages: entry.messages ++ messages}

      _ ->
        entry
    end
  end
end
