defmodule LangueTest.Formatter.ARB.Expectation do
  alias Langue.Entry

  defmodule Empty do
    use Langue.Expectation.Case

    def render, do: "{}\n"
    def entries, do: []
  end

  defmodule Simple do
    use Langue.Expectation.Case

    def render do
      """
      {
        "@@last_modified": "2020-01-08T11:39:22.562134",
        "pushCounterText": "You have pushed the button this many times:",
        "@pushCounterText": {
          "description": "A description for the push counter",
          "type": "text",
          "placeholders": {}
        }
      }
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "pushCounterText", value: "You have pushed the button this many times:"}
      ]
    end

    def meta do
      %{
        "@@last_modified" => %{"index" => 0, "value" => "2020-01-08T11:39:22.562134"},
        "@pushCounterText" => %{
          "index" => 2,
          "value" => %{
            "description" => %{
              "index" => 0,
              "value" => "A description for the push counter"
            },
            "placeholders" => %{"index" => 2, "value" => %{}},
            "type" => %{"index" => 1, "value" => "text"}
          }
        },
        "pushCounterText" => %{
          "index" => 1,
          "value" => "You have pushed the button this many times:"
        }
      }
    end
  end

  defmodule Harder do
    use Langue.Expectation.Case

    def render do
      """
      {
        "@@locale": "en_US",
        "@@context": "HomePage",
        "title_bar": "My Cool Home",
        "@title_bar": {
          "type": "text",
          "context": "HomePage",
          "description": "Page title."
        },
        "MSG_OK": "Everything works fine.",
        "FOO_123": "Your pending cost is {COST}",
        "@FOO_123": {
          "type": "text",
          "context": "HomePage:MainPanel",
          "description": "balance statement.",
          "source_text": "Your pending cost is {COST}",
          "placeholders": {
            "COST": {
              "example": "$123.45",
              "description": "cost presented with currency symbol"
            }
          },
          "screen": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAQMAAAAlPW0iAAAABlBMVEUAAAD///+l2Z/dAAAAM0lEQVR4nGP4/5/h/1+G/58ZDrAz3D/McH8yw83NDDeNGe4Ug9C9zwz3gVLMDA/A6P9/AFGGFyjOXZtQAAAAAElFTkSuQmCC",
          "video": "http://www.youtube.com/ajigliech"
        },
        "BAR_231": "images/image_bar.jpg",
        "@BAR_231": {
          "type": "image",
          "context": "HomePage:MainPanel",
          "description": "brand image",
          "screen": "file://screenshot/welcome_page.jpg",
          "video": "http://www.youtube.com/user_interaction.mp4"
        },
        "FOOTER_STYLE": "#footer:{font-family: arial}",
        "@FOOTER_STYLE": {
          "context": "HomePage"
        }
      }
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "title_bar", value: "My Cool Home"},
        %Entry{index: 2, key: "MSG_OK", value: "Everything works fine."},
        %Entry{index: 3, key: "FOO_123", value: "Your pending cost is {COST}"},
        %Entry{index: 4, key: "BAR_231", value: "images/image_bar.jpg"},
        %Entry{index: 5, key: "FOOTER_STYLE", value: "#footer:{font-family: arial}"}
      ]
    end

    def meta do
      %{
        "@@context" => %{"index" => 1, "value" => "HomePage"},
        "@@locale" => %{"index" => 0, "value" => "en_US"},
        "@BAR_231" => %{
          "index" => 8,
          "value" => %{
            "context" => %{"index" => 1, "value" => "HomePage:MainPanel"},
            "description" => %{"index" => 2, "value" => "brand image"},
            "screen" => %{
              "index" => 3,
              "value" => "file://screenshot/welcome_page.jpg"
            },
            "type" => %{"index" => 0, "value" => "image"},
            "video" => %{
              "index" => 4,
              "value" => "http://www.youtube.com/user_interaction.mp4"
            }
          }
        },
        "@FOOTER_STYLE" => %{
          "index" => 10,
          "value" => %{"context" => %{"index" => 0, "value" => "HomePage"}}
        },
        "@FOO_123" => %{
          "index" => 6,
          "value" => %{
            "context" => %{"index" => 1, "value" => "HomePage:MainPanel"},
            "description" => %{"index" => 2, "value" => "balance statement."},
            "placeholders" => %{
              "index" => 4,
              "value" => %{
                "COST" => %{
                  "index" => 0,
                  "value" => %{
                    "description" => %{
                      "index" => 1,
                      "value" => "cost presented with currency symbol"
                    },
                    "example" => %{"index" => 0, "value" => "$123.45"}
                  }
                }
              }
            },
            "screen" => %{
              "index" => 5,
              "value" =>
                "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAQMAAAAlPW0iAAAABlBMVEUAAAD///+l2Z/dAAAAM0lEQVR4nGP4/5/h/1+G/58ZDrAz3D/McH8yw83NDDeNGe4Ug9C9zwz3gVLMDA/A6P9/AFGGFyjOXZtQAAAAAElFTkSuQmCC"
            },
            "source_text" => %{"index" => 3, "value" => "Your pending cost is {COST}"},
            "type" => %{"index" => 0, "value" => "text"},
            "video" => %{"index" => 6, "value" => "http://www.youtube.com/ajigliech"}
          }
        },
        "@title_bar" => %{
          "index" => 3,
          "value" => %{
            "context" => %{"index" => 1, "value" => "HomePage"},
            "description" => %{"index" => 2, "value" => "Page title."},
            "type" => %{"index" => 0, "value" => "text"}
          }
        },
        "BAR_231" => %{"index" => 7, "value" => "images/image_bar.jpg"},
        "FOOTER_STYLE" => %{"index" => 9, "value" => "#footer:{font-family: arial}"},
        "FOO_123" => %{"index" => 5, "value" => "Your pending cost is {COST}"},
        "MSG_OK" => %{"index" => 4, "value" => "Everything works fine."},
        "title_bar" => %{"index" => 2, "value" => "My Cool Home"}
      }
    end
  end

  defmodule NoMeta do
    use Langue.Expectation.Case

    def render do
      """
      {
        "pushCounterText": "You have pushed the button this many times:",
        "anotherKey": "Abc"
      }
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "pushCounterText", value: "You have pushed the button this many times:"},
        %Entry{index: 2, key: "anotherKey", value: "Abc"}
      ]
    end

    def meta do
      %{
        "pushCounterText" => %{
          "index" => 0,
          "value" => "You have pushed the button this many times:"
        },
        "anotherKey" => %{
          "index" => 1,
          "value" => "Abc"
        }
      }
    end
  end
end
