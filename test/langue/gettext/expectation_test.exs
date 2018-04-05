defmodule AccentTest.Formatter.Gettext.Expectation do
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
        %Entry{index: 2, key: "should be at least n character(s).__KEY___", value: "should be at least %{count} character(s)", value_type: "plural"},
        %Entry{index: 2, key: "should be at least n character(s).__KEY__0", value: "should be at least 0 characters", value_type: "plural"},
        %Entry{index: 2, key: "should be at least n character(s).__KEY__1", value: "should be at least %{count} character(s)", value_type: "plural"}
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
end
