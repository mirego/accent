defmodule LangueTest.Formatter.Gettext.Expectation do
  alias Langue.Entry

  defmodule Simple do
    use Langue.Expectation.Case

    def render do
      """
      #{top_of_the_file_comment()}msgid ""
      msgstr ""
      #{header()}
      ## From Ecto.Changeset.cast/4
      msgid "can't be blank"
      msgstr "ne peut être vide"

      ## From Ecto.Changeset.unique_constraint/3
      msgid "has already been taken"
      msgstr "est déjà pris"
      """
    end

    def entries do
      [
        %Entry{comment: "## From Ecto.Changeset.cast/4", index: 1, key: "can't be blank", value: "ne peut être vide"},
        %Entry{comment: "## From Ecto.Changeset.unique_constraint/3", index: 2, key: "has already been taken", value: "est déjà pris"}
      ]
    end

    def top_of_the_file_comment do
      ~S"""
      ## `msgid`s in this file come from POT (.pot) files.
      ##
      ## Do not add, change, or remove `msgid`s manually here as
      ## they're tied to the ones in the corresponding POT file
      ## (with the same domain).
      ##
      ## Use `mix gettext.extract --merge` or `mix gettext.merge`
      ## to merge POT files into PO files.
      """
    end

    def header do
      ~S"""
      "Language: fr"
      """
    end
  end

  defmodule Pluralization do
    use Langue.Expectation.Case

    def render do
      """
      msgid "has already been taken"
      msgstr "est déjà pris"

      msgid "should be at least n character(s)"
      msgid_plural "should be at least %{count} character(s)"
      msgstr[0] "should be at least 0 characters"
      msgstr[1] "should be at least %{count} character(s)"
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "has already been taken", value: "est déjà pris"},
        %Entry{
          index: 2,
          key: "should be at least n character(s).__KEY___",
          value: "should be at least %{count} character(s)",
          plural: true,
          locked: true,
          value_type: "string",
          placeholders: ~w(%{count})
        },
        %Entry{index: 3, key: "should be at least n character(s).__KEY__0", value: "should be at least 0 characters", plural: true, value_type: "string"},
        %Entry{
          index: 4,
          key: "should be at least n character(s).__KEY__1",
          value: "should be at least %{count} character(s)",
          plural: true,
          value_type: "string",
          placeholders: ~w(%{count})
        }
      ]
    end
  end

  defmodule DotKeys do
    use Langue.Expectation.Case

    def render do
      """
      msgid "has already been taken"
      msgstr "est déjà pris"

      msgid "has.already.been.taken"
      msgstr "est déjà pris"
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "has already been taken", value: "est déjà pris"},
        %Entry{index: 2, key: "has.already.been.taken", value: "est déjà pris"}
      ]
    end
  end

  defmodule LanguageHeader do
    use Langue.Expectation.Case

    def render do
      """
      msgid ""
      msgstr ""
      #{header()}
      msgid "has already been taken"
      msgstr "est déjà pris"
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "has already been taken", value: "est déjà pris"}
      ]
    end

    def header do
      ~S"""
      "Language: "
      """
    end
  end

  defmodule PluralFormsHeader do
    use Langue.Expectation.Case

    def render do
      """
      msgid ""
      msgstr ""
      #{header()}
      msgid "has already been taken"
      msgstr "est déjà pris"
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "has already been taken", value: "est déjà pris"}
      ]
    end

    def header do
      ~S"""
      "Plural-Forms: nplurals=2; plural=(n > 1);"
      """
    end
  end

  defmodule NewLines do
    use Langue.Expectation.Case

    def render do
      """
      msgid "test"
      msgstr "a\\n"
      "a\\n"
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "test", value: "a\na\n"}
      ]
    end
  end

  defmodule EmptyComment do
    use Langue.Expectation.Case

    def render do
      """
      msgid "test"
      msgstr "a"
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "test", value: "a", comment: ""}
      ]
    end
  end

  defmodule PlaceholderValues do
    use Langue.Expectation.Case

    def render do
      """
      msgid "single"
      msgstr "Hello, %{username}."

      msgid "multiple"
      msgstr "Hello, %{firstname} %{lastname}."

      msgid "duplicate"
      msgstr "Hello, %{username}. Welcome back %{username}."

      msgid "empty"
      msgstr "Hello, %{}."
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "single", value: "Hello, %{username}.", placeholders: ~w(%{username})},
        %Entry{index: 2, key: "multiple", value: "Hello, %{firstname} %{lastname}.", placeholders: ~w(%{firstname} %{lastname})},
        %Entry{index: 3, key: "duplicate", value: "Hello, %{username}. Welcome back %{username}.", placeholders: ~w(%{username} %{username})},
        %Entry{index: 4, key: "empty", value: "Hello, %{}.", placeholders: ~w(%{})}
      ]
    end
  end

  defmodule ContextValues do
    use Langue.Expectation.Case

    def render do
      """
      msgid "test duplicate"
      msgstr "a"

      msgctxt "other"
      msgid "test duplicate"
      msgstr "a"
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "test duplicate", value: "a"},
        %Entry{index: 2, key: "test duplicate.__KEY__other", value: "a", context: "other"}
      ]
    end
  end
end
