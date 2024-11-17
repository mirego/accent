defmodule Accent.Prompts do
  @moduledoc false
  alias Accent.Prompts.Provider

  def config_or_default(config) do
    default_provider = Application.get_env(:accent, __MODULE__)[:use_provider_by_default]

    if is_nil(config) and is_binary(default_provider) do
      %{"provider" => default_provider, "use_platform" => true}
    else
      config
    end
  end

  def id_from_config(config) do
    provider = provider_from_config(config)
    Provider.id(provider)
  end

  def completions(prompt, user_input, config) do
    provider = provider_from_config(config)
    Provider.completions(provider, prompt, user_input)
  end

  def enabled?(config) do
    provider = provider_from_config(config)
    Provider.enabled?(provider)
  end

  defp provider_from_config(nil), do: %Provider.NotImplemented{}

  defp provider_from_config(config) do
    struct_module =
      case config["provider"] do
        "openai" -> Provider.OpenAI
        _ -> Provider.NotImplemented
      end

    struct!(struct_module, config: fetch_config(config))
  end

  defp fetch_config(%{"provider" => provider, "use_platform" => true}) do
    Map.get(Application.get_env(:accent, __MODULE__)[:default_providers_config], provider)
  end

  defp fetch_config(%{"config" => config}), do: config
end
