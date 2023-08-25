defmodule Movement.TranslationComparer do
  @moduledoc """
  Receives a translation marked to be removed

  ## Examples

    iex> Movement.TranslationComparer.compare(%{marked_as_removed: true}, "test")
    {"remove", nil}

  Receives a removed translation

  ## Examples

    iex> Movement.TranslationComparer.compare(%{removed: true}, "test")
    {"renew", "test"}

  Receives a translation with a corrected text,
  where the corrected text is not equal to text
  and proposed text is equal to text

  ## Examples

    iex> Movement.TranslationComparer.compare(%{proposed_text: "Hello", corrected_text: "Hi"}, "Hello")
    {"autocorrect", "Hi"}

  Receives a translation with a corrected text,
  where the corrected text is equal to text

  ## Examples

    iex> Movement.TranslationComparer.compare(%{proposed_text: "Hi", corrected_text: "Hi"}, "Hi")
    {"noop", "Hi"}

  Receives a translation with a corrected text,
  where the corrected text is equal to text

  ## Examples

    iex> Movement.TranslationComparer.compare(%{proposed_text: "Hello", corrected_text: "Hi"}, "Hi")
    {"update_proposed", "Hi"}

  Receives a translation with no corrected text,
  where the proposed text is not equal to text

  ## Examples

    iex> Movement.TranslationComparer.compare(%{proposed_text: "Hello", corrected_text: "Hello"}, "Hi")
    {"conflict_on_proposed", "Hi"}

  Receives a translation with corrected text,
  where the proposed text is not equal to text
  and the corrected text is not equal to text

  ## Examples

    iex> Movement.TranslationComparer.compare(%{proposed_text: "Hello", corrected_text: "Hi"}, "Welcome")
    {"conflict_on_corrected", "Welcome"}

  No condition matches

  ## Examples

    iex> Movement.TranslationComparer.compare(%{}, "Welcome")
    {"new", "Welcome"}

  Nil translation

  ## Examples

    iex> Movement.TranslationComparer.compare(nil, "Welcome")
    {"new", "Welcome"}
  """
  # All action types and minus "conflict_on_slave" which can only be added by SlaveConflictBuilder.
  @noop "noop"
  @autocorrect "autocorrect"
  @update_proposed "update_proposed"
  @conflict_on_proposed "conflict_on_proposed"
  @conflict_on_corrected "conflict_on_corrected"
  @new "new"
  @renew "renew"
  @remove "remove"

  def compare(%{marked_as_removed: true}, _text), do: {@remove, nil}
  def compare(%{removed: true}, text), do: {@renew, text}

  def compare(%{proposed_text: proposed, corrected_text: corrected}, text) when proposed == text and corrected != text,
    do: {@autocorrect, corrected}

  def compare(%{corrected_text: corrected, proposed_text: proposed}, text) when proposed == text and corrected == text,
    do: {@noop, text}

  def compare(%{corrected_text: corrected}, text) when corrected == text, do: {@update_proposed, text}

  def compare(%{proposed_text: proposed, corrected_text: corrected}, text)
      when proposed != text and corrected == proposed,
      do: {@conflict_on_proposed, text}

  def compare(%{proposed_text: proposed, corrected_text: corrected}, text) when proposed != text and corrected != text,
    do: {@conflict_on_corrected, text}

  def compare(_, text), do: {@new, text}
end
