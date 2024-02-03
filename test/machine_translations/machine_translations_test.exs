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
                   "mimeType" => "text/html",
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
                   "mimeType" => "text/html",
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
  end
end
