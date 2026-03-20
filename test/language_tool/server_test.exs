defmodule LanguageToolTest.Server do
  @moduledoc false
  use ExUnit.Case, async: false

  alias LanguageTool.Server.Config

  @moduletag :languagetool

  @fake_script Path.join([__DIR__, "..", "support", "fake_languagetool.sh"])

  defp open_fake_port do
    bash = System.find_executable("bash")
    Port.open({:spawn_executable, bash}, [:binary, :exit_status, {:line, 1_048_576}, {:args, [@fake_script]}])
  end

  defp build_state(port) do
    config = %Config{languages: ["en", "fr"], disabled_rule_ids: []}
    %{config: config, port: port, queue: :queue.new(), buffer: ""}
  end

  defp make_from do
    ref = make_ref()
    {ref, {self(), ref}}
  end

  defp json_payload(text) do
    JSON.encode!(%{items: [%{text: text}]})
  end

  describe "Config.parse/1" do
    test "parses valid config" do
      config = Config.parse(languages: ["en"], disabled_rule_ids: ["RULE1"])
      assert config.languages === ["en"]
      assert config.disabled_rule_ids === ["RULE1"]
    end

    test "defaults disabled_rule_ids to empty list" do
      config = Config.parse(languages: ["en"])
      assert config.disabled_rule_ids === []
    end

    test "raises on missing languages" do
      assert_raise KeyError, fn ->
        Config.parse(disabled_rule_ids: [])
      end
    end
  end

  describe "init/1" do
    test "returns :ignore when languages is empty" do
      assert :ignore ===
               LanguageTool.Server.init(%{config: [languages: [], disabled_rule_ids: []]})
    end

    test "starts and schedules init_port when languages present" do
      {:ok, state} = LanguageTool.Server.init(%{config: [languages: ["en"], disabled_rule_ids: []]})
      assert state.config.languages === ["en"]
      assert state.port === nil
      assert :queue.is_empty(state.queue)
      assert :persistent_term.get({:language_tool, :ready}) === false
      assert MapSet.member?(:persistent_term.get({:language_tool, :languages}), "en")

      assert_receive :init_port, 100
    end
  end

  describe "handle_call {:check} with nil port" do
    test "replies nil immediately" do
      state = %{config: nil, port: nil, queue: :queue.new(), buffer: ""}
      {ref, from} = make_from()

      assert {:noreply, ^state} = LanguageTool.Server.handle_call({:check, "en", "text"}, from, state)

      assert_receive {^ref, nil}
    end
  end

  describe "handle_call {:check} with active port" do
    setup do
      port = open_fake_port()
      assert_receive {^port, {:data, {:eol, ">"}}}, 5_000
      on_exit(fn -> catch_error(Port.close(port)) end)
      {:ok, port: port, state: build_state(port)}
    end

    test "enqueues from and writes to port", %{port: port, state: state} do
      {_ref, from} = make_from()
      payload = json_payload("hello")

      assert {:noreply, new_state} = LanguageTool.Server.handle_call({:check, "en", payload}, from, state)
      assert :queue.len(new_state.queue) === 1

      assert_receive {^port, {:data, {:eol, _response}}}, 5_000
    end

    test "sanitizes en to en-US", %{port: port, state: state} do
      {_ref, from} = make_from()
      payload = json_payload("hello")

      {:noreply, new_state} = LanguageTool.Server.handle_call({:check, "en", payload}, from, state)

      assert_receive {^port, {:data, {:eol, response}}}, 5_000

      {:noreply, _state} = LanguageTool.Server.handle_info({port, {:data, {:eol, response}}}, new_state)

      {ref, _} = from
      assert_receive {^ref, %{"language" => "en-US"}}
    end

    test "preserves non-en language codes", %{port: port, state: state} do
      {ref, from} = make_from()
      payload = json_payload("bonjour")

      {:noreply, new_state} = LanguageTool.Server.handle_call({:check, "fr", payload}, from, state)
      assert_receive {^port, {:data, {:eol, response}}}, 5_000

      {:noreply, _state} = LanguageTool.Server.handle_info({port, {:data, {:eol, response}}}, new_state)

      assert_receive {^ref, %{"language" => "fr"}}
    end

    test "full request-response cycle returns decoded JSON", %{port: port, state: state} do
      {ref, from} = make_from()
      payload = json_payload("testing")

      {:noreply, state} = LanguageTool.Server.handle_call({:check, "fr", payload}, from, state)
      assert_receive {^port, {:data, {:eol, response}}}, 5_000

      {:noreply, final_state} = LanguageTool.Server.handle_info({port, {:data, {:eol, response}}}, state)
      assert :queue.is_empty(final_state.queue)

      assert_receive {^ref, %{"language" => "fr", "text" => "fake_response", "matches" => [], "markups" => []}}
    end
  end

  describe "pipelining" do
    setup do
      port = open_fake_port()
      assert_receive {^port, {:data, {:eol, ">"}}}, 5_000
      on_exit(fn -> catch_error(Port.close(port)) end)
      {:ok, port: port, state: build_state(port)}
    end

    test "multiple concurrent requests are queued and replied in FIFO order", %{port: port, state: state} do
      {ref1, from1} = make_from()
      {ref2, from2} = make_from()
      {ref3, from3} = make_from()

      {:noreply, state} = LanguageTool.Server.handle_call({:check, "en", json_payload("first")}, from1, state)
      {:noreply, state} = LanguageTool.Server.handle_call({:check, "fr", json_payload("second")}, from2, state)
      {:noreply, state} = LanguageTool.Server.handle_call({:check, "en", json_payload("third")}, from3, state)

      assert :queue.len(state.queue) === 3

      responses =
        for _ <- 1..3 do
          assert_receive {^port, {:data, {:eol, resp}}}, 5_000
          resp
        end

      state =
        Enum.reduce(responses, state, fn resp, acc ->
          {:noreply, new_state} = LanguageTool.Server.handle_info({port, {:data, {:eol, resp}}}, acc)
          new_state
        end)

      assert :queue.is_empty(state.queue)

      assert_receive {^ref1, %{"language" => "en-US"}}
      assert_receive {^ref2, %{"language" => "fr"}}
      assert_receive {^ref3, %{"language" => "en-US"}}
    end

    test "interleaved handle_call and handle_info", %{port: port, state: state} do
      {ref1, from1} = make_from()
      {:noreply, state} = LanguageTool.Server.handle_call({:check, "fr", json_payload("one")}, from1, state)
      assert_receive {^port, {:data, {:eol, resp1}}}, 5_000

      {:noreply, state} = LanguageTool.Server.handle_info({port, {:data, {:eol, resp1}}}, state)
      assert_receive {^ref1, %{"language" => "fr"}}

      {ref2, from2} = make_from()
      {:noreply, state} = LanguageTool.Server.handle_call({:check, "en", json_payload("two")}, from2, state)
      assert_receive {^port, {:data, {:eol, resp2}}}, 5_000

      {:noreply, state} = LanguageTool.Server.handle_info({port, {:data, {:eol, resp2}}}, state)
      assert_receive {^ref2, %{"language" => "en-US"}}

      assert :queue.is_empty(state.queue)
    end
  end

  describe "handle_info port data" do
    setup do
      port = open_fake_port()
      assert_receive {^port, {:data, {:eol, ">"}}}, 5_000
      on_exit(fn -> catch_error(Port.close(port)) end)
      {:ok, port: port, state: build_state(port)}
    end

    test "ready signal sets persistent_term to true", %{port: port} do
      :persistent_term.put({:language_tool, :ready}, false)
      state = build_state(port)

      {:noreply, _state} = LanguageTool.Server.handle_info({port, {:data, {:eol, ">"}}}, state)

      assert :persistent_term.get({:language_tool, :ready}) === true
    end

    test "eol with empty queue logs warning but does not crash", %{port: port, state: state} do
      valid_json = JSON.encode!(%{"language" => "en", "text" => "test", "matches" => [], "markups" => []})

      assert {:noreply, ^state} = LanguageTool.Server.handle_info({port, {:data, {:eol, valid_json}}}, state)
    end

    test "noeol buffers partial data", %{port: port, state: state} do
      {:noreply, state} = LanguageTool.Server.handle_info({port, {:data, {:noeol, "partial"}}}, state)
      assert state.buffer === "partial"

      {:noreply, state} = LanguageTool.Server.handle_info({port, {:data, {:noeol, "_more"}}}, state)
      assert state.buffer === "partial_more"
    end

    test "eol after noeol concatenates buffer before decode", %{port: port, state: state} do
      {ref, from} = make_from()
      payload = json_payload("hello")
      {:noreply, state} = LanguageTool.Server.handle_call({:check, "fr", payload}, from, state)

      assert_receive {^port, {:data, {:eol, full_response}}}, 5_000

      part1 = binary_slice(full_response, 0, 10)
      part2 = binary_slice(full_response, 10, byte_size(full_response) - 10)

      {:noreply, state} = LanguageTool.Server.handle_info({port, {:data, {:noeol, part1}}}, state)
      assert state.buffer === part1

      {:noreply, state} = LanguageTool.Server.handle_info({port, {:data, {:eol, part2}}}, state)
      assert state.buffer === ""

      assert_receive {^ref, %{"language" => "fr"}}
    end

    test "malformed JSON in response raises", %{port: port, state: state} do
      {_ref, from} = make_from()
      state = %{state | queue: :queue.in(from, state.queue)}

      assert_raise JSON.DecodeError, fn ->
        LanguageTool.Server.handle_info({port, {:data, {:eol, "not valid json{{"}}}, state)
      end
    end
  end

  describe "handle_info exit_status" do
    test "drains queue, resets state, schedules restart" do
      port = open_fake_port()
      assert_receive {^port, {:data, {:eol, ">"}}}, 5_000

      {ref1, from1} = make_from()
      {ref2, from2} = make_from()

      state = build_state(port)
      state = %{state | queue: :queue.in(from1, :queue.in(from2, state.queue))}
      :persistent_term.put({:language_tool, :ready}, true)

      {:noreply, new_state} = LanguageTool.Server.handle_info({port, {:exit_status, 1}}, state)

      assert new_state.port === nil
      assert :queue.is_empty(new_state.queue)
      assert new_state.buffer === ""
      assert :persistent_term.get({:language_tool, :ready}) === false

      assert_receive {^ref1, nil}
      assert_receive {^ref2, nil}

      assert_receive :init_port, 6_000
    end
  end

  describe "handle_info catch-all" do
    test "ignores unknown messages" do
      state = %{config: nil, port: nil, queue: :queue.new(), buffer: ""}
      assert {:noreply, ^state} = LanguageTool.Server.handle_info(:unknown, state)
    end
  end

  describe "available?/0" do
    test "returns false when java is not found and jar missing" do
      original_path = System.get_env("PATH")
      System.put_env("PATH", "/nonexistent")

      refute LanguageTool.Server.available?()

      System.put_env("PATH", original_path)
    end
  end

  describe "list_languages/0" do
    test "reads from persistent_term" do
      :persistent_term.put({:language_tool, :languages}, MapSet.new(["en", "de"]))
      assert LanguageTool.Server.list_languages() === MapSet.new(["en", "de"])
    end
  end

  describe "ready?/0" do
    test "reads from persistent_term" do
      :persistent_term.put({:language_tool, :ready}, true)
      assert LanguageTool.Server.ready?() === true

      :persistent_term.put({:language_tool, :ready}, false)
      assert LanguageTool.Server.ready?() === false
    end
  end
end
