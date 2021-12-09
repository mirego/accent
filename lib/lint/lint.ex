defmodule Accent.Lint do
  @typep entry :: Langue.Entry.t()

  defmodule Entry do
    @enforce_keys ~w(value master_value messages language translation_id)a
    defstruct value: nil, master_value: nil, messages: [], language: nil, translation_id: nil
  end

  defmodule Message do
    @enforce_keys ~w(check text replacement)a
    defstruct check: nil, text: nil, replacement: nil
  end

  defmodule Replacement do
    @enforce_keys ~w(value label)a
    defstruct value: nil, label: nil
  end

  @spec lint(list(entry)) :: list(map())
  def lint(entries) do
    entries
    |> Enum.map(&map_to_entry/1)
    |> :lint.lint()
    |> Enum.map(&entry_to_map/1)
    |> Task.async_stream(&Accent.Lint.Autocorrect.autocorrect/1)
    |> Enum.flat_map(fn
      {:ok, entry} -> [entry]
      _ -> []
    end)
  end

  defp map_to_entry(map) do
    {:entry, map.value, map.master_value, map.is_master, map.language_slug, map.id, []}
  end

  defp entry_to_map({:entry, value, master_value, _, language, translation_id, messages}) do
    %Entry{
      value: value,
      master_value: master_value,
      language: language,
      translation_id: translation_id,
      messages: Enum.map(messages, &entry_message/1)
    }
  end

  defp entry_message({check, text, {:some, {_, replacement_value, replacement_label}}}) do
    %Message{
      check: check,
      text: text,
      replacement: %Replacement{value: replacement_value, label: replacement_label}
    }
  end

  defp entry_message({check, text, :none}) do
    %Message{check: check, text: text, replacement: nil}
  end
end
