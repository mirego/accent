defmodule LanguageToolTest.AnnotatedText do
  @moduledoc false
  use ExUnit.Case, async: true

  alias LanguageTool.AnnotatedText

  @moduletag :languagetool

  describe "build/2 plain text" do
    test "returns single text item for plain text" do
      assert AnnotatedText.build("hello world", nil) === [%{text: "hello world"}]
    end

    test "empty string returns empty list" do
      assert AnnotatedText.build("", nil) === []
    end

    test "single character returns empty list (byte_size guard)" do
      assert AnnotatedText.build("a", nil) === []
    end

    test "two characters returns text item" do
      assert AnnotatedText.build("ab", nil) === [%{text: "ab"}]
    end

    test "whitespace-only text returns text item" do
      assert AnnotatedText.build("   ", nil) === [%{text: "   "}]
    end

    test "text with newlines preserved" do
      assert AnnotatedText.build("hello\nworld", nil) === [%{text: "hello\nworld"}]
    end

    test "unicode text preserved" do
      assert AnnotatedText.build("héllo wörld", nil) === [%{text: "héllo wörld"}]
    end

    test "emoji text preserved" do
      assert AnnotatedText.build("hello 🌍 world", nil) === [%{text: "hello 🌍 world"}]
    end
  end

  describe "build/2 regex parameter" do
    test "nil regex produces no entry regex matches" do
      assert AnnotatedText.build("hello world", nil) === [%{text: "hello world"}]
    end

    test ":not_supported regex produces no entry regex matches" do
      assert AnnotatedText.build("hello world", :not_supported) === [%{text: "hello world"}]
    end

    test "custom entry regex marks matches as markup with x" do
      regex = ~r/\{\{[^}]+\}\}/

      assert AnnotatedText.build("hello {{name}} world", regex) === [
               %{text: "hello "},
               %{markup: "{{name}}", markupAs: "x"},
               %{text: " world"}
             ]
    end

    test "custom entry regex with multiple matches" do
      regex = ~r/\{\{[^}]+\}\}/

      assert AnnotatedText.build("{{greeting}} dear {{name}}", regex) === [
               %{markup: "{{greeting}}", markupAs: "x"},
               %{text: " dear "},
               %{markup: "{{name}}", markupAs: "x"}
             ]
    end
  end

  describe "build/2 HTML" do
    test "HTML tags become markup with empty markupAs" do
      assert AnnotatedText.build("hello <b>world</b>", nil) === [
               %{text: "hello "},
               %{markup: "<b>", markupAs: ""},
               %{text: "world"},
               %{markup: "</b>", markupAs: ""}
             ]
    end

    test "self-closing HTML tags" do
      assert AnnotatedText.build("hello<br/>world", nil) === [
               %{text: "hello"},
               %{markup: "<br/>", markupAs: ""},
               %{text: "world"}
             ]
    end

    test "nested HTML tags" do
      assert AnnotatedText.build("<p><b>bold</b></p>", nil) === [
               %{markup: "<p>", markupAs: ""},
               %{markup: "<b>", markupAs: ""},
               %{text: "bold"},
               %{markup: "</b>", markupAs: ""},
               %{markup: "</p>", markupAs: ""}
             ]
    end

    test "HTML with attributes" do
      assert AnnotatedText.build("click <a href=\"url\">here</a>", nil) === [
               %{text: "click "},
               %{markup: "<a href=\"url\">", markupAs: ""},
               %{text: "here"},
               %{markup: "</a>", markupAs: ""}
             ]
    end
  end

  describe "build/2 placeholders" do
    test "percent placeholder becomes markup with x" do
      assert AnnotatedText.build("hello %name", nil) === [
               %{text: "hello "},
               %{markup: "%name", markupAs: "x"}
             ]
    end

    test "dollar placeholder becomes markup with x" do
      assert AnnotatedText.build("hello $var1", nil) === [
               %{text: "hello "},
               %{markup: "$var1", markupAs: "x"}
             ]
    end

    test "multiple placeholders" do
      assert AnnotatedText.build("%greeting dear %name", nil) === [
               %{markup: "%greeting", markupAs: "x"},
               %{text: " dear "},
               %{markup: "%name", markupAs: "x"}
             ]
    end

    test "adjacent placeholders with no text between" do
      assert AnnotatedText.build("%foo%bar", nil) === [
               %{markup: "%foo", markupAs: "x"},
               %{markup: "%bar", markupAs: "x"}
             ]
    end

    test "numeric placeholders" do
      assert AnnotatedText.build("item %1 of %2", nil) === [
               %{text: "item "},
               %{markup: "%1", markupAs: "x"},
               %{text: " of "},
               %{markup: "%2", markupAs: "x"}
             ]
    end
  end

  describe "build/2 empty string delimiter" do
    test "empty string with delimiter becomes markup with (x" do
      result = AnnotatedText.build("value is (\"\") here", nil)

      assert result === [
               %{text: "value is "},
               %{markup: "(\"\"", markupAs: "(x"},
               %{text: ") here"}
             ]
    end
  end

  describe "build/2 mixed content" do
    test "HTML and placeholders sorted by position" do
      assert AnnotatedText.build("hello <b>%name</b>", nil) === [
               %{text: "hello "},
               %{markup: "<b>", markupAs: ""},
               %{markup: "%name", markupAs: "x"},
               %{markup: "</b>", markupAs: ""}
             ]
    end

    test "multiple placeholder types in same text" do
      assert AnnotatedText.build("hello %name <em>$value</em>", nil) === [
               %{text: "hello "},
               %{markup: "%name", markupAs: "x"},
               %{text: " "},
               %{markup: "<em>", markupAs: ""},
               %{markup: "$value", markupAs: "x"},
               %{markup: "</em>", markupAs: ""}
             ]
    end

    test "custom regex combined with HTML and placeholders" do
      regex = ~r/\{\{[^}]+\}\}/

      result = AnnotatedText.build("{{var}} is <b>%name</b>", regex)

      assert result === [
               %{markup: "{{var}}", markupAs: "x"},
               %{text: " is "},
               %{markup: "<b>", markupAs: ""},
               %{markup: "%name", markupAs: "x"},
               %{markup: "</b>", markupAs: ""}
             ]
    end

    test "only markup content with no plain text" do
      assert AnnotatedText.build("<b></b>", nil) === [
               %{markup: "<b>", markupAs: ""},
               %{markup: "</b>", markupAs: ""}
             ]
    end

    test "text ending with markup" do
      assert AnnotatedText.build("hello %name", nil) === [
               %{text: "hello "},
               %{markup: "%name", markupAs: "x"}
             ]
    end

    test "text starting with markup" do
      assert AnnotatedText.build("<b>hello</b> world", nil) === [
               %{markup: "<b>", markupAs: ""},
               %{text: "hello"},
               %{markup: "</b>", markupAs: ""},
               %{text: " world"}
             ]
    end
  end
end
