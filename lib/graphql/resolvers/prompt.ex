defmodule Accent.GraphQL.Resolvers.Prompt do
  alias Accent.{
    Plugs.GraphQLContext,
    Project,
    Prompt,
    PromptConfigManager,
    PromptManager,
    Prompts
  }

  @spec improve_text(Accent.Prompt.t(), any(), GraphQLContext.t()) :: {:ok, %{provider: atom(), text: String.t(), error: String.t() | nil}}
  def improve_text(prompt, args, _info) do
    result = %{
      text: nil,
      error: nil,
      provider: Prompts.id_from_config(prompt.project.prompt_config)
    }

    result =
      case Prompts.completions(prompt, args.text, prompt.project.prompt_config) do
        [%{text: text} | _] -> %{result | text: text}
        {:error, error} when is_atom(error) -> %{result | error: to_string(error)}
        _ -> result
      end

    {:ok, result}
  end

  @spec save_config(Project.t(), any(), GraphQLContext.t()) :: {:ok, %{project: Project.t() | nil, errors: [String.t()] | nil}}
  def save_config(project, args, _info) do
    case PromptConfigManager.save(project, args) do
      {:ok, %{project: project}} ->
        {:ok, %{project: project, errors: nil}}

      {:error, _reason, _, _} ->
        {:ok, %{project: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec delete_config(Project.t(), any(), GraphQLContext.t()) :: {:ok, %{project: Project.t() | nil, errors: [String.t()] | nil}}
  def delete_config(project, _args, _info) do
    case PromptConfigManager.delete(project) do
      {:ok, %{project: project}} ->
        {:ok, %{project: project, errors: nil}}

      {:error, _reason, _, _} ->
        {:ok, %{project: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec delete(Prompt.t(), any(), GraphQLContext.t()) :: {:ok, %{prompt: Prompt.t() | nil, errors: [String.t()] | nil}}
  def delete(prompt, _args, _info) do
    case PromptManager.delete(prompt) do
      {:ok, %{prompt: prompt}} ->
        {:ok, %{prompt: prompt, errors: nil}}

      {:error, _reason, _, _} ->
        {:ok, %{prompt: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec update(Prompt.t(), any(), GraphQLContext.t()) :: {:ok, %{prompt: Prompt.t() | nil, errors: [String.t()] | nil}}
  def update(prompt, args, _info) do
    case PromptManager.update(prompt, args) do
      {:ok, %{prompt: prompt}} ->
        {:ok, %{prompt: prompt, errors: nil}}

      {:error, _reason, _, _} ->
        {:ok, %{prompt: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec create(Project.t(), any(), GraphQLContext.t()) :: {:ok, %{prompt: Prompt.t() | nil, errors: [String.t()] | nil}}
  def create(project, args, %{context: context}) do
    current_user = context[:conn].assigns[:current_user]

    case PromptManager.create(project, args, current_user) do
      {:ok, %{prompt: prompt}} ->
        {:ok, %{prompt: prompt, errors: nil}}

      {:error, _reason, _, _} ->
        {:ok, %{prompt: nil, errors: ["unprocessable_entity"]}}
    end
  end
end
