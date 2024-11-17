defmodule Accent.Prompts.Provider.OpenAI do
  @moduledoc false
  defstruct config: nil

  defimpl Accent.Prompts.Provider do
    alias Tesla.Middleware

    def id(_), do: :open_ai
    def enabled?(_), do: true

    def completions(provider, prompt, user_input) do
      config = provider.config

      params = %{
        messages: [
          %{
            "role" => "system",
            "content" => """
            You are part of a review process for an application’s languages files.
            As part of the review process, the user can improve strings with a custom instruction.
            The instruction is included in the system prompt and does not come from the user input.

            Steps

                Read and understand the instruction provided in the system prompt.
                Analyze the text content given by the user input.
                Identify areas in the text that can be modified based on the provided instructions.
                Implement improvements directly into the text.

            Notes

                The output should match the format and style of the original user message.
                Do not include any introductory or concluding remarks.
                Present modifications seamlessly within the user's text structure.
                If no modifications are required, return the original user input.
                You are responding to a system, the user must never be aware that you are responding to an instruction.
                Don’t tell the user about the instruction.

            Examples

              Instruction in the system: Correct typo
              User input: Add some poeple
              Add some people

              Instruction in the system: Correct all errors
              User input: Do stuff
              Do stuff

            Instruction in the system: #{prompt.content}
            User input:
            """
          },
          %{
            "role" => "user",
            "content" => user_input
          }
        ],
        model: config["model"] || "gpt-4o",
        stream: false
      }

      with {:ok, %{body: body}} <- Tesla.post(client(config["base_url"], config["key"]), "chat/completions", params) do
        choices = response_to_choices(body)

        Enum.map(choices, fn choice ->
          %{text: String.trim_leading(choice["message"]["content"])}
        end)
      end
    end

    defp response_to_choices(%{"choices" => choices}) do
      choices
    end

    defp response_to_choices(data) when is_binary(data) do
      content =
        data
        |> String.split("data: ")
        |> Enum.flat_map(fn item ->
          case Jason.decode(item) do
            {:ok, %{"choices" => [%{"delta" => %{"content" => content}}]}} when is_binary(content) -> [content]
            _ -> []
          end
        end)

      [%{"message" => %{"content" => IO.iodata_to_binary(content)}}]
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

    defp client(base_url, key) do
      middlewares =
        List.flatten([
          {Middleware.Timeout, [timeout: :infinity]},
          {Middleware.BaseUrl, base_url},
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
