defmodule Accent.Prompts.Provider.OpenAI do
  @moduledoc false
  defstruct config: nil

  defimpl Accent.Prompts.Provider do
    alias Tesla.Middleware

    def id(_), do: :open_ai
    def enabled?(_), do: true

    def completions(provider, prompt, user_input) do
      config = provider.config["config"]

      params = %{
        messages: [
          %{
            "role" => "system",
            "content" =>
              ~s{Following this instruction "#{prompt.content}", respond with the improved text in the user’s message format without repeating the instructions.}
          },
          %{
            "role" => "user",
            "content" => user_input
          }
        ],
        model: config["model"] || "gpt-3.5-turbo",
        max_tokens: config["max_tokens"] || 1000,
        temperature: config["temperature"] || 0
      }

      with {:ok, %{body: %{"choices" => choices}}} <-
             Tesla.post(client(config["key"]), "chat/completions", params) do
        Enum.map(choices, fn choice ->
          %{text: String.trim_leading(choice["message"]["content"])}
        end)
      end
    end

    defmodule Auth do
      @moduledoc false
      @behaviour Tesla.Middleware

      @impl Tesla.Middleware
      def call(env, next, opts) do
        env
        |> Tesla.put_header("authorization", "Bearer #{opts[:key]}")
        |> Tesla.run(next)
      end
    end

    defp client(key) do
      middlewares =
        List.flatten([
          {Middleware.Timeout, [timeout: :infinity]},
          {Middleware.BaseUrl, "https://api.openai.com/v1/"},
          {Auth, [key: key]},
          Middleware.DecodeJson,
          Middleware.EncodeJson,
          Middleware.Logger,
          Middleware.Telemetry
        ])

      Tesla.client(middlewares)
    end
  end
end
