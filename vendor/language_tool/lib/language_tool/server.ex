defmodule LanguageTool.Server do
  @moduledoc false
  use GenServer

  require Logger

  defmodule Config do
    @moduledoc false
    defstruct languages: [], disabled_rule_ids: []

    def parse(opts) do
      %__MODULE__{
        languages: Keyword.fetch!(opts, :languages),
        disabled_rule_ids: Keyword.get(opts, :disabled_rule_ids, [])
      }
    end
  end

  def start_link(config) do
    GenServer.start_link(__MODULE__, %{config: config}, name: __MODULE__)
  end

  def list_languages do
    :persistent_term.get({:language_tool, :languages})
  end

  def ready? do
    :persistent_term.get({:language_tool, :ready})
  end

  def available? do
    !!System.find_executable("java") and File.exists?(jar_file())
  end

  @impl GenServer
  def init(state) do
    config = Config.parse(state.config)
    :persistent_term.put({:language_tool, :config}, config)
    :persistent_term.put({:language_tool, :languages}, MapSet.new(config.languages))
    :persistent_term.put({:language_tool, :ready}, false)

    if Enum.empty?(config.languages) do
      Logger.info(
        "LanguageTool was not configured. Use LANGUAGE_TOOL_LANGUAGES environment variable to set a list of comma-separated languages short code."
      )

      :ignore
    else
      Process.send_after(self(), :init_port, 1)

      {:ok, %{config: config, port: nil, queue: :queue.new(), buffer: ""}}
    end
  end

  @impl GenServer
  def handle_call({:check, _lang, _text}, from, %{port: nil} = state) do
    GenServer.reply(from, nil)
    {:noreply, state}
  end

  def handle_call({:check, lang, text}, from, state) do
    lang = sanitize_lang(lang)
    Port.command(state.port, [String.pad_trailing(lang, 7), text, "\n"])
    {:noreply, %{state | queue: :queue.in(from, state.queue)}}
  end

  @impl GenServer
  def handle_info(:init_port, state) do
    case start_port(state.config) do
      nil ->
        Logger.info("LanguageTool was unable to start")
        :persistent_term.put({:language_tool, :ready}, false)
        {:noreply, state}

      port ->
        {:noreply, %{state | port: port}}
    end
  end

  def handle_info({port, {:data, {:eol, ">"}}}, %{port: port} = state) do
    Logger.info("LanguageTool is ready to spellcheck")
    :persistent_term.put({:language_tool, :ready}, true)
    {:noreply, state}
  end

  def handle_info({port, {:data, {:eol, line}}}, %{port: port} = state) do
    full_line = state.buffer <> line
    state = %{state | buffer: ""}

    case :queue.out(state.queue) do
      {{:value, from}, queue} ->
        response = JSON.decode!(full_line)
        GenServer.reply(from, response)
        {:noreply, %{state | queue: queue}}

      {:empty, _queue} ->
        Logger.warning("LanguageTool received unexpected output: #{String.slice(full_line, 0, 200)}")
        {:noreply, state}
    end
  end

  def handle_info({port, {:data, {:noeol, partial}}}, %{port: port} = state) do
    {:noreply, %{state | buffer: state.buffer <> partial}}
  end

  def handle_info({port, {:exit_status, status}}, %{port: port} = state) do
    Logger.error("LanguageTool process exited with status #{status}")
    :persistent_term.put({:language_tool, :ready}, false)
    drain_queue(state.queue)
    Process.send_after(self(), :init_port, 5_000)
    {:noreply, %{state | port: nil, queue: :queue.new(), buffer: ""}}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  defp start_port(config) do
    java = System.find_executable("java")

    if java && File.exists?(jar_file()) do
      args =
        ["-cp", jar_file(), "com.mirego.accent.languagetool.AppKt", "--languages", Enum.join(config.languages, ",")] ++
          disabled_rule_args(config)

      Port.open({:spawn_executable, java}, [:binary, :exit_status, {:line, 10_485_760}, {:args, args}])
    else
      Logger.warning("LanguageTool could not be started. Install JRE and build the jar in #{jar_file()} to enable it")
      nil
    end
  end

  defp disabled_rule_args(%{disabled_rule_ids: []}), do: []
  defp disabled_rule_args(%{disabled_rule_ids: ids}), do: ["--disabledRuleIds", Enum.join(ids, ",")]

  defp jar_file do
    Path.join(Application.app_dir(:accent, "priv/native"), "language-tool.jar")
  end

  defp sanitize_lang("en"), do: "en-US"
  defp sanitize_lang(lang), do: lang

  defp drain_queue(queue) do
    case :queue.out(queue) do
      {{:value, from}, rest} ->
        GenServer.reply(from, nil)
        drain_queue(rest)

      {:empty, _} ->
        :ok
    end
  end
end
