defmodule Accent.Vault do
  @moduledoc false
  use Cloak.Vault, otp_app: :accent, json_library: Jason

  # Reference: https://hexdocs.pm/cloak_ecto/generate_keys.html
  @default_key "pJhJ9q2qmMXYUCR0HyfufqtHQ+W1rqsr9M5q2aYo6Lo="

  @impl GenServer
  def init(config) do
    config =
      Keyword.put(
        config,
        :ciphers,
        default: {
          Cloak.Ciphers.AES.GCM,
          tag: "AES.GCM.V1", key: decode_env!("MACHINE_TRANSLATIONS_VAULT_KEY")
        }
      )

    {:ok, config}
  end

  defp decode_env!(var) do
    var
    |> System.get_env(@default_key)
    |> Base.decode64!()
  end
end
