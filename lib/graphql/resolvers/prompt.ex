defmodule Accent.GraphQL.Resolvers.Prompt do
  @moduledoc false
  alias Accent.Plugs.GraphQLContext
  alias Accent.Project
  alias Accent.Prompt
  alias Accent.PromptConfigManager
  alias Accent.PromptManager
  alias Accent.Prompts

  @spec improve_text(Accent.Prompt.t(), any(), GraphQLContext.t()) ::
          {:ok, %{provider: atom(), text: String.t(), errors: [String.t()] | nil}}
  def improve_text(prompt, args, _info) do
    config = Prompts.config_or_default(prompt.project.prompt_config)

    result = %{
      text: nil,
      errors: nil,
      provider: Prompts.id_from_config(config)
    }

    result =
      case Prompts.completions(prompt, args.text, config) do
        [%{text: text} | _] -> %{result | text: text}
        _ -> %{result | text: "", errors: ["internal_server_error"]}
      end

    {:ok, result}
  end

  @spec save_config(Project.t(), any(), GraphQLContext.t()) ::
          {:ok, %{project: Project.t() | nil, errors: [String.t()] | nil}}
  def save_config(project, args, _info) do
    case PromptConfigManager.save(project, args) do
      {:ok, %{project: project}} ->
        {:ok, %{project: project, errors: nil}}

      {:error, _reason, _, _} ->
        {:ok, %{project: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec delete_config(Project.t(), any(), GraphQLContext.t()) ::
          {:ok, %{project: Project.t() | nil, errors: [String.t()] | nil}}
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

  @spec project_config(Project.t(), any(), GraphQLContext.t()) ::
          {:ok, %{provider: String.t(), use_platform: boolean(), use_config_key: boolean()} | nil}
  def project_config(project, _, _) do
    config = Prompts.config_or_default(project.prompt_config)

    if is_nil(config) do
      {:ok, nil}
    else
      {:ok,
       %{
         provider: config["provider"],
         use_platform: config["use_platform"] || false,
         use_config_key: not is_nil(config["config"]["key"])
       }}
    end
  end
end
