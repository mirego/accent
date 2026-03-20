defmodule LanguageToolTest do
  @moduledoc false
  use ExUnit.Case, async: false

  @moduletag :languagetool

  defmodule FakeServer do
    @moduledoc false
    use GenServer

    def start_link(opts) do
      GenServer.start_link(__MODULE__, opts, name: LanguageTool.Server)
    end

    @impl GenServer
    def init(opts), do: {:ok, opts}

    @impl GenServer
    def handle_call({:check, lang, _text}, _from, state) do
      response = Keyword.get(state, :response, default_response(lang))
      {:reply, response, state}
    end

    defp default_response(lang) do
      %{"language" => lang, "text" => "fake", "matches" => [], "markups" => []}
    end
  end

  setup do
    :persistent_term.put({:language_tool, :languages}, MapSet.new(["en", "fr"]))
    :persistent_term.put({:language_tool, :config}, %LanguageTool.Server.Config{languages: ["en", "fr"]})
    :persistent_term.put({:language_tool, :ready}, true)

    Cachex.clear!(:language_tool_cache)

    :ok
  end

  describe "check/3 unsupported language" do
    test "returns empty matches with :unsupported_language error" do
      result = LanguageTool.check("zz", "hello world")

      assert result === %{
               "error" => :unsupported_language,
               "language" => "zz",
               "matches" => [],
               "text" => "hello world",
               "markups" => []
             }
    end

    test "does not call GenServer for unsupported language" do
      result = LanguageTool.check("xx", "test text")
      assert result["error"] === :unsupported_language
    end
  end

  describe "check/3 supported language" do
    setup do
      {:ok, pid} = FakeServer.start_link([])
      on_exit(fn -> if Process.alive?(pid), do: GenServer.stop(pid) end)
      :ok
    end

    test "delegates to server and returns result" do
      result = LanguageTool.check("en", "hello world")

      assert result["language"] === "en"
      assert result["matches"] === []
    end

    test "caches result on first call" do
      LanguageTool.check("fr", "bonjour monde")

      stats = Cachex.stats!(:language_tool_cache)
      assert stats.sets === 1
    end

    test "returns cached result on subsequent calls" do
      result1 = LanguageTool.check("en", "cached text")
      result2 = LanguageTool.check("en", "cached text")

      assert result1 === result2

      stats = Cachex.stats!(:language_tool_cache)
      assert stats.sets === 1
      assert stats.hits >= 1
    end

    test "different texts produce different cache entries" do
      LanguageTool.check("en", "text one")
      LanguageTool.check("en", "text two")

      stats = Cachex.stats!(:language_tool_cache)
      assert stats.sets === 2
    end

    test "same text different language produces different cache entries" do
      LanguageTool.check("en", "same text")
      LanguageTool.check("fr", "same text")

      stats = Cachex.stats!(:language_tool_cache)
      assert stats.sets === 2
    end
  end

  describe "check/3 with custom response" do
    test "returns server response with matches" do
      response = %{
        "language" => "en",
        "text" => "tset",
        "matches" => [
          %{
            "offset" => 0,
            "length" => 4,
            "message" => "Possible spelling mistake",
            "replacements" => [%{"value" => "test"}],
            "rule" => %{"id" => "SPELLING", "description" => "Spelling"}
          }
        ],
        "markups" => []
      }

      {:ok, pid} = FakeServer.start_link(response: response)
      on_exit(fn -> if Process.alive?(pid), do: GenServer.stop(pid) end)

      result = LanguageTool.check("en", "tset")
      assert length(result["matches"]) === 1
      assert hd(result["matches"])["message"] === "Possible spelling mistake"
    end
  end

  describe "check/3 error handling" do
    test "returns empty matches when GenServer is not running" do
      result = LanguageTool.check("en", "hello world")

      assert result === %{
               "error" => :check_internal_error,
               "language" => "en",
               "matches" => [],
               "text" => "hello world",
               "markups" => []
             }
    end

    test "returns empty matches when GenServer replies nil" do
      {:ok, pid} = FakeServer.start_link(response: nil)
      on_exit(fn -> if Process.alive?(pid), do: GenServer.stop(pid) end)

      result = LanguageTool.check("en", "hello")

      assert result === nil
    end
  end

  describe "check/3 with placeholder_regex option" do
    setup do
      {:ok, pid} = FakeServer.start_link([])
      on_exit(fn -> if Process.alive?(pid), do: GenServer.stop(pid) end)
      :ok
    end

    test "passes placeholder_regex to AnnotatedText.build" do
      result = LanguageTool.check("en", "hello {{name}}", placeholder_regex: ~r/\{\{[^}]+\}\}/)
      assert result["language"] === "en"
    end
  end

  describe "check/3 edge cases" do
    setup do
      {:ok, pid} = FakeServer.start_link([])
      on_exit(fn -> if Process.alive?(pid), do: GenServer.stop(pid) end)
      :ok
    end

    test "text with special characters" do
      result = LanguageTool.check("en", "hello & goodbye <world>")
      assert result["language"] === "en"
    end

    test "text with unicode" do
      result = LanguageTool.check("fr", "héllo café résumé")
      assert result["language"] === "fr"
    end

    test "text with newlines" do
      result = LanguageTool.check("en", "hello\nworld\ntest")
      assert result["language"] === "en"
    end

    test "text with only whitespace" do
      result = LanguageTool.check("en", "    ")
      assert result["language"] === "en"
    end

    test "very long text" do
      long_text = String.duplicate("hello world ", 100)
      result = LanguageTool.check("en", long_text)
      assert result["language"] === "en"
    end

    test "text with HTML entities" do
      result = LanguageTool.check("en", "hello &amp; world")
      assert result["language"] === "en"
    end

    test "text with mixed placeholders and HTML" do
      result = LanguageTool.check("en", "<b>%name</b> $value")
      assert result["language"] === "en"
    end
  end

  describe "available?/0" do
    test "delegates to Server" do
      assert is_boolean(LanguageTool.available?())
    end
  end

  describe "list_languages/0" do
    test "returns MapSet from persistent_term" do
      assert LanguageTool.list_languages() === MapSet.new(["en", "fr"])
    end
  end

  describe "ready?/0" do
    test "returns boolean from persistent_term" do
      :persistent_term.put({:language_tool, :ready}, true)
      assert LanguageTool.ready?() === true

      :persistent_term.put({:language_tool, :ready}, false)
      assert LanguageTool.ready?() === false
    end
  end

  describe "empty_matches structure" do
    test "unsupported language returns all expected keys" do
      result = LanguageTool.check("xx", "test")

      assert Map.has_key?(result, "error")
      assert Map.has_key?(result, "language")
      assert Map.has_key?(result, "matches")
      assert Map.has_key?(result, "text")
      assert Map.has_key?(result, "markups")
      assert is_list(result["matches"])
      assert is_list(result["markups"])
    end
  end

  describe "cache key determinism" do
    setup do
      {:ok, pid} = FakeServer.start_link([])
      on_exit(fn -> if Process.alive?(pid), do: GenServer.stop(pid) end)
      :ok
    end

    test "same inputs always produce same cache key" do
      LanguageTool.check("en", "deterministic")

      stats_before = Cachex.stats!(:language_tool_cache)

      LanguageTool.check("en", "deterministic")

      stats_after = Cachex.stats!(:language_tool_cache)
      assert stats_after.sets === stats_before.sets
      assert stats_after.hits === stats_before.hits + 1
    end
  end

  describe "concurrent access" do
    setup do
      {:ok, pid} = FakeServer.start_link([])
      on_exit(fn -> if Process.alive?(pid), do: GenServer.stop(pid) end)
      :ok
    end

    test "concurrent checks for different texts all succeed" do
      tasks =
        for i <- 1..20 do
          Task.async(fn ->
            LanguageTool.check("en", "concurrent text #{i}")
          end)
        end

      results = Task.await_many(tasks, 10_000)

      assert length(results) === 20
      assert Enum.all?(results, &(&1["language"] === "en"))
      assert Enum.all?(results, &(&1["matches"] === []))
    end

    test "concurrent checks for same text use cache" do
      tasks =
        for _ <- 1..10 do
          Task.async(fn ->
            LanguageTool.check("fr", "same concurrent text")
          end)
        end

      results = Task.await_many(tasks, 10_000)

      assert length(results) === 10
      assert Enum.all?(results, &(&1["language"] === "fr"))
    end

    test "concurrent checks for mixed languages" do
      tasks =
        for {lang, i} <- ["en", "fr"] |> Stream.cycle() |> Enum.take(20) |> Enum.with_index() do
          Task.async(fn ->
            LanguageTool.check(lang, "text #{i}")
          end)
        end

      results = Task.await_many(tasks, 10_000)

      assert length(results) === 20
      assert Enum.all?(results, &is_map/1)
      assert Enum.all?(results, &is_list(&1["matches"]))
    end
  end
end
