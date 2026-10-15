defmodule AccentTest.MachineTranslations do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Accent.MachineTranslations
  alias Plug.Conn

  defp stub(url, response_fun) do
    Req.Test.stub(Accent.HTTPClient, fn conn ->
      assert "#{conn.scheme}://#{conn.host}#{conn.request_path}" === url
      {status, body} = response_fun.(conn)

      case body do
        body when is_binary(body) -> Conn.send_resp(conn, status, body)
        body -> conn |> Conn.put_status(status) |> Req.Test.json(body)
      end
    end)
  end

  defp read_body(conn) do
    {:ok, body, _conn} = Conn.read_body(conn)
    body
  end

  describe "translate/2" do
    test "google_translate" do
      stub("https://translation.googleapis.com/v3/projects/1234/:translateText", fn conn ->
        body = read_body(conn)

        assert JSON.decode!(body) === %{
                 "contents" => ["Test"],
                 "mimeType" => "text/plain",
                 "sourceLanguageCode" => "fr",
                 "targetLanguageCode" => "en"
               }

        {200, %{"translations" => [%{"translatedText" => "Translated"}]}}
      end)

      entries = [%Langue.Entry{value: "Test", value_type: "string", key: "."}]
      source_language = "fr"
      target_language = "en"
      provider_config = %{"key" => JSON.encode!(%{"project_id" => "1234", "type" => "service_account"})}
      config = %{"provider" => "google_translate", "config" => provider_config}

      [entry] = MachineTranslations.translate(entries, source_language, target_language, config)
      assert entry.value === "Translated"
    end

    test "google_translate no translate span" do
      stub("https://translation.googleapis.com/v3/projects/1234/:translateText", fn conn ->
        body = read_body(conn)

        assert JSON.decode!(body) === %{
                 "contents" => [~s(Test <span translate="no">%{placeholder}</span> bla)],
                 "mimeType" => "text/plain",
                 "sourceLanguageCode" => "fr",
                 "targetLanguageCode" => "en"
               }

        {200,
         %{
           "translations" => [%{"translatedText" => ~s(Translated <span translate="no">%{placeholder}</span> bla)}]
         }}
      end)

      entries = [%Langue.Entry{value: "Test %{placeholder} bla", value_type: "string", key: "."}]
      source_language = "fr"
      target_language = "en"
      provider_config = %{"key" => JSON.encode!(%{"project_id" => "1234", "type" => "service_account"})}
      config = %{"provider" => "google_translate", "config" => provider_config}

      [entry] = MachineTranslations.translate(entries, source_language, target_language, config)
      assert entry.value === "Translated %{placeholder} bla"
    end

    test "google_translate error" do
      stub("https://translation.googleapis.com/v3/projects/1234/:translateText", fn _conn ->
        {400, "Something"}
      end)

      entries = [%Langue.Entry{value: "Test", value_type: "string", key: "."}]
      source_language = "fr"
      target_language = "en"
      provider_config = %{"key" => JSON.encode!(%{"project_id" => "1234", "type" => "service_account"})}
      config = %{"provider" => "google_translate", "config" => provider_config}

      {:error, error} = MachineTranslations.translate(entries, source_language, target_language, config)
      assert error === "Something"
    end

    test "deepl" do
      stub("https://api-free.deepl.com/v2/translate", fn conn ->
        body = read_body(conn)

        assert JSON.decode!(body) === %{"source_lang" => "FR", "target_lang" => "EN", "text" => ["Test"]}

        {200, %{"translations" => [%{"text" => "Translated"}]}}
      end)

      entries = [%Langue.Entry{value: "Test", value_type: "string", key: "."}]
      source_language = "fr"
      target_language = "en"
      provider_config = %{"key" => "test:fx"}
      config = %{"provider" => "deepl", "config" => provider_config}

      [entry] = MachineTranslations.translate(entries, source_language, target_language, config)
      assert entry.value === "Translated"
    end

    test "deepl pro" do
      stub("https://api.deepl.com/v2/translate", fn conn ->
        body = read_body(conn)

        assert JSON.decode!(body) === %{"source_lang" => "FR", "target_lang" => "EN", "text" => ["Test"]}

        {200, %{"translations" => [%{"text" => "Translated"}]}}
      end)

      entries = [%Langue.Entry{value: "Test", value_type: "string", key: "."}]
      source_language = "fr"
      target_language = "en"
      provider_config = %{"key" => "test-pro"}
      config = %{"provider" => "deepl", "config" => provider_config}

      [entry] = MachineTranslations.translate(entries, source_language, target_language, config)
      assert entry.value === "Translated"
    end

    test "deepl error" do
      stub("https://api-free.deepl.com/v2/translate", fn _conn ->
        {400, "Something"}
      end)

      entries = [%Langue.Entry{value: "Test", value_type: "string", key: "."}]
      source_language = "fr"
      target_language = "en"
      provider_config = %{"key" => "test:fx"}
      config = %{"provider" => "deepl", "config" => provider_config}

      {:error, error} = MachineTranslations.translate(entries, source_language, target_language, config)
      assert error === "Something"
    end

    test "deepl detect source" do
      stub("https://api-free.deepl.com/v2/translate", fn _conn ->
        {400, "Something"}
      end)

      entries = [%Langue.Entry{value: "Test", value_type: "string", key: "."}]
      target_language = "en"
      provider_config = %{"key" => "test:fx"}
      config = %{"provider" => "deepl", "config" => provider_config}

      {:error, error} = MachineTranslations.translate(entries, nil, target_language, config)
      assert error === "Something"
    end
  end
end
