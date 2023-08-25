defmodule LangueTest.Formatter.Gettext.Expectation do
  @moduledoc false
  alias Langue.Entry

  defmodule Simple do
    @moduledoc false
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

      msgid "empty value"
      msgstr ""
      """
    end

    def entries do
      [
        %Entry{
          comment: "## From Ecto.Changeset.cast/4",
          index: 1,
          key: "can't be blank",
          value: "ne peut être vide",
          value_type: "string"
        },
        %Entry{
          comment: "## From Ecto.Changeset.unique_constraint/3",
          index: 2,
          key: "has already been taken",
          value: "est déjà pris",
          value_type: "string"
        },
        %Entry{index: 3, key: "empty value", value: "", value_type: "empty"}
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
      String.trim_trailing(~S"""
      "Language: fr"
      """)
    end
  end

  defmodule Pluralization do
    @moduledoc false
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
        %Entry{index: 1, key: "has already been taken", value: "est déjà pris", value_type: "string"},
        %Entry{
          index: 2,
          key: "should be at least n character(s).__KEY___",
          value: "should be at least %{count} character(s)",
          plural: true,
          locked: true,
          value_type: "plural",
          placeholders: ~w(%{count})
        },
        %Entry{
          index: 3,
          key: "should be at least n character(s).__KEY__0",
          value: "should be at least 0 characters",
          plural: true,
          value_type: "string"
        },
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
    @moduledoc false
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
        %Entry{index: 1, key: "has already been taken", value: "est déjà pris", value_type: "string"},
        %Entry{index: 2, key: "has.already.been.taken", value: "est déjà pris", value_type: "string"}
      ]
    end
  end

  defmodule LanguageHeader do
    @moduledoc false
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
        %Entry{index: 1, key: "has already been taken", value: "est déjà pris", value_type: "string"}
      ]
    end

    def header do
      String.trim_trailing(~S"""
      "Language: fr"
      """)
    end
  end

  defmodule PluralFormsHeader do
    @moduledoc false
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
        %Entry{index: 1, key: "has already been taken", value: "est déjà pris", value_type: "string"}
      ]
    end

    def header do
      String.trim_trailing(~S"""
      "Plural-Forms: nplurals=2; plural=(n > 1);"
      """)
    end
  end

  defmodule NewLines do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      msgid "test"
      msgstr "This is a test\\n"
      "\\n"
      "multi line break"
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "test", value: "This is a test\n\nmulti line break", value_type: "string"}
      ]
    end
  end

  defmodule EmptyComment do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      msgid "test"
      msgstr "a"
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "test", value: "a", comment: "", value_type: "string"}
      ]
    end
  end

  defmodule PlaceholderValues do
    @moduledoc false
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
        %Entry{
          index: 1,
          key: "single",
          value: "Hello, %{username}.",
          placeholders: ~w(%{username}),
          value_type: "string"
        },
        %Entry{
          index: 2,
          key: "multiple",
          value: "Hello, %{firstname} %{lastname}.",
          placeholders: ~w(%{firstname} %{lastname}),
          value_type: "string"
        },
        %Entry{
          index: 3,
          key: "duplicate",
          value: "Hello, %{username}. Welcome back %{username}.",
          placeholders: ~w(%{username} %{username}),
          value_type: "string"
        },
        %Entry{index: 4, key: "empty", value: "Hello, %{}.", placeholders: ~w(%{}), value_type: "string"}
      ]
    end
  end

  defmodule HeaderLineBreak do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      #{top_of_the_file_comment()}msgid ""
      msgstr ""
      #{header()}

      msgid "key"
      msgstr "value"
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "key", value: "value", value_type: "string"}
      ]
    end

    def top_of_the_file_comment do
      ~S"""
      # SOME DESCRIPTIVE TITLE.
      # Copyright (C) YEAR THE PACKAGE'S COPYRIGHT HOLDER
      # This file is distributed under the same license as the PACKAGE package.
      # FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.
      #
      """
    end

    def header do
      String.trim_trailing(~S"""
      "Project-Id-Version: PACKAGE VERSION\n"
      "Report-Msgid-Bugs-To: \n"
      "POT-Creation-Date: 2019-08-13 11:32+0200\n"
      "PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\n"
      "Last-Translator: FULL NAME <EMAIL@ADDRESS>\n"
      "Language-Team: LANGUAGE <LL@li.org>\n"
      "MIME-Version: 1.0\n"
      "Content-Type: text/plain; charset=UTF-8\n"
      "Content-Transfer-Encoding: 8bit\n"
      """)
    end
  end

  defmodule ContextValues do
    @moduledoc false
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
        %Entry{index: 1, key: "test duplicate", value: "a", value_type: "string"},
        %Entry{index: 2, key: "test duplicate.__CONTEXT__other", value: "a", value_type: "string"}
      ]
    end
  end
end
