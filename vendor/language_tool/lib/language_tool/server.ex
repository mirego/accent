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

  def init(state) do
    config = Config.parse(state.config)
    :persistent_term.put({:language_tool, :config}, config)
    :persistent_term.put({:language_tool, :ready}, false)

    if Enum.empty?(config.languages) do
      Logger.info(
        "LanguageTool was not configured. Use LANGUAGE_TOOL_LANGUAGES environment variable to set a list of comma-separated languages short code."
      )

      :ignore
    else
      Process.send_after(self(), :init_server_process, 1)

      {:ok, %{state | config: config}}
    end
  end

  def start_link(config) do
    GenServer.start_link(__MODULE__, %{config: config, backend: nil}, name: __MODULE__)
  end

  def list_languages do
    :persistent_term.get({:language_tool, :config}).languages
  end

  def ready? do
    :persistent_term.get({:language_tool, :ready})
  end

  def available? do
    LanguageTool.Backend.available?()
  end

  def handle_call({:check, lang, text}, _, state) do
    response = LanguageTool.Backend.check(state.backend, lang, text)
    {:reply, response, state}
  end

  def handle_info(:init_server_process, state) do
    case LanguageTool.Backend.start(state.config) do
      nil ->
        Logger.info("LanguageTool was unable to start")
        :persistent_term.put({:language_tool, :ready}, false)
        {:noreply, state}

      backend ->
        Logger.info("LanguageTool is ready to spellcheck")

        state = %{state | backend: backend}
        :persistent_term.put({:language_tool, :ready}, true)

        {:noreply, state}
    end
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end
end
