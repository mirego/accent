defmodule Accent.GraphQL.Types.Prompt do
  use Absinthe.Schema.Notation

  enum :prompt_provider do
    value(:not_implemented)
    value(:openai)
  end

  object :prompt do
    field(:id, non_null(:id))
    field(:quick_access, :string)
    field(:name, :string)

    field(:display_name, non_null(:string),
      resolve: fn prompt, _, _ ->
        {:ok, prompt.name || prompt.content}
      end
    )

    field(:content, non_null(:string))
  end
end
