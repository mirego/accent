defmodule AccentTest.MachineTranslations do
  @moduledoc false
  use ExUnit.Case, async: false

  import Tesla.Mock

  alias Accent.MachineTranslations

  describe "translate/2" do
    test "google_translate" do
      mock_global(fn
        %{body: body, url: "https://translation.googleapis.com/v3/projects/1234/:translateText"} ->
          assert Jason.decode!(body) === %{
                   "contents" => ["Test"],
                   "mimeType" => "text/plain",
                   "sourceLanguageCode" => "fr",
                   "targetLanguageCode" => "en"
                 }

          %Tesla.Env{status: 200, body: %{"translations" => [%{"translatedText" => "Translated"}]}}
      end)

      entries = [%Langue.Entry{value: "Test", value_type: "string", key: "."}]
      source_language = "fr"
      target_language = "en"
      provider_config = %{"key" => Jason.encode!(%{"project_id" => "1234", "type" => "service_account"})}
      config = %{"provider" => "google_translate", "config" => provider_config}

      [entry] = MachineTranslations.translate(entries, source_language, target_language, config)
      assert entry.value === "Translated"
    end

    test "google_translate no translate span" do
      mock_global(fn
        %{body: body, url: "https://translation.googleapis.com/v3/projects/1234/:translateText"} ->
          assert Jason.decode!(body) === %{
                   "contents" => [~s(Test <span translate="no">%{placeholder}</span> bla)],
                   "mimeType" => "text/plain",
                   "sourceLanguageCode" => "fr",
                   "targetLanguageCode" => "en"
                 }

          %Tesla.Env{
            status: 200,
            body: %{
              "translations" => [%{"translatedText" => ~s(Translated <span translate="no">%{placeholder}</span> bla)}]
            }
          }
      end)

      entries = [%Langue.Entry{value: "Test %{placeholder} bla", value_type: "string", key: "."}]
      source_language = "fr"
      target_language = "en"
      provider_config = %{"key" => Jason.encode!(%{"project_id" => "1234", "type" => "service_account"})}
      config = %{"provider" => "google_translate", "config" => provider_config}

      [entry] = MachineTranslations.translate(entries, source_language, target_language, config)
      assert entry.value === "Translated %{placeholder} bla"
    end

    test "google_translate error" do
      mock_global(fn
        %{url: "https://translation.googleapis.com/v3/projects/1234/:translateText"} ->
          %Tesla.Env{status: 400, body: "Something"}
      end)

      entries = [%Langue.Entry{value: "Test", value_type: "string", key: "."}]
      source_language = "fr"
      target_language = "en"
      provider_config = %{"key" => Jason.encode!(%{"project_id" => "1234", "type" => "service_account"})}
      config = %{"provider" => "google_translate", "config" => provider_config}

      {:error, error} = MachineTranslations.translate(entries, source_language, target_language, config)
      assert error === "Something"
    end

    test "deepl" do
      mock_global(fn
        %{body: body, url: "https://api-free.deepl.com/v2/translate"} ->
          assert Jason.decode!(body) === %{"source_lang" => "FR", "target_lang" => "EN", "text" => ["Test"]}

          %Tesla.Env{status: 200, body: %{"translations" => [%{"text" => "Translated"}]}}
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
      mock_global(fn
        %{body: body, url: "https://api.deepl.com/v2/translate"} ->
          assert Jason.decode!(body) === %{"source_lang" => "FR", "target_lang" => "EN", "text" => ["Test"]}

          %Tesla.Env{status: 200, body: %{"translations" => [%{"text" => "Translated"}]}}
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
      mock_global(fn %{url: "https://api-free.deepl.com/v2/translate"} ->
        %Tesla.Env{status: 400, body: "Something"}
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
      mock_global(fn %{url: "https://api-free.deepl.com/v2/translate"} ->
        %Tesla.Env{status: 400, body: "Something"}
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
