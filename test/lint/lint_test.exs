defmodule AccentTest.Lint do
  use ExUnit.Case, async: true

  alias Accent.Lint
  alias Langue.Entry

  test "lint valid entry" do
    entry = %Entry{value: "foo", master_value: "foo"}
    [linted] = Lint.lint([entry])

    assert linted.entry === entry
    assert linted.messages === []
  end

  test "lint trailing space entry" do
    entry = %Entry{value: "foo ", master_value: "foo"}
    [linted] = Lint.lint([entry])

    assert linted.entry.value === "foo"
    assert linted.messages === [fix: ~s(Value contains trailing space: "foo " should be "foo")]
  end

  test "lint leading space entry" do
    entry = %Entry{value: " foo", master_value: "foo"}
    [linted] = Lint.lint([entry])

    assert linted.entry.value === "foo"
    assert linted.messages === [fix: ~s(Value contains leading space: " foo" should be "foo")]
  end

  test "lint placeholder count entry" do
    entry = %Entry{value: "foo", master_value: "foo %{bar}"}
    [linted] = Lint.lint([entry])

    assert linted.entry.value === "foo"
    assert linted.messages === [error: "Value contains a different number of placeholders (0) from the master value (1)"]
  end

  test "lint url count entry" do
    entry = %Entry{value: "foo", master_value: "foo https://google.ca"}
    [linted] = Lint.lint([entry])

    assert linted.entry.value === "foo"
    assert linted.messages === [error: "Value contains a different number of URL (0) from the master value (1)"]
  end

  test "lint single quote entry for fr language" do
    entry = %Entry{value: "J'arrive", master_value: "I'm coming"}
    [linted] = Lint.lint([entry], language: "fr")

    assert linted.entry.value === "J’arrive"
    assert linted.messages === [fix: ~s(Value contains single quotes where an apostrophe should be used: "J'arrive" should be "J’arrive")]
  end

  test "lint space before punctuation entry for fr-CA language" do
    entry = %Entry{value: "C’est magnifique !", master_value: "Cool"}
    [linted] = Lint.lint([entry], language: "fr-CA")

    assert linted.entry.value === "C’est magnifique!"
    assert linted.messages === [fix: ~s(Value contains invalid space before punctuation: "C’est magnifique !" should be "C’est magnifique!")]
  end
end
