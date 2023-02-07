defmodule Accent.Vault do
  use Cloak.Vault, otp_app: :accent, json_library: Jason

  @impl GenServer
  def init(config) do
    config =
      Keyword.put(
        config,
        :ciphers,
        default: {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: decode_env!("MACHINE_TRANSLATIONS_VAULT_KEY")}
      )

    {:ok, config}
  end

  defp decode_env!(key_name) do
    key_name
    |> System.get_env()
    |> Base.decode64!()
  end
end
