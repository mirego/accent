defmodule LangueTest.Formatter.LaravelPhp.Expectation do
  @moduledoc false
  alias Langue.Entry

  defmodule ParsesDoubleQuotations do
    @moduledoc false
    use Langue.Expectation.Case

    def render do
      """
      <?php

      return [
        'required'=>'Le champ :attribute est obligatoire.',
        'required_if'=>'Le champ :attribute est obligatoire quand la valeur de :other est :value.',
        'required_with'=>'Le champ :attribute est obligatoire quand :values est présent.',
        'same'=>'Les champs :attribute et :other doivent être identiques.',
        'size'=>[
          'numeric'=>'La taille de la valeur de :attribute doit être :size.',
          'file'=>'La taille du fichier de :attribute doit être de :size kilobytes.',
          'string'=>'Le texte de :attribute doit contenir :size caractères.'
          ]
        ];
      """
    end

    def entries do
      [
        %Entry{index: 1, key: "required", value: "Le champ :attribute est obligatoire.", value_type: "string"},
        %Entry{
          index: 2,
          key: "required_if",
          value: "Le champ :attribute est obligatoire quand la valeur de :other est :value.",
          value_type: "string"
        },
        %Entry{
          index: 3,
          key: "required_with",
          value: "Le champ :attribute est obligatoire quand :values est présent.",
          value_type: "string"
        },
        %Entry{
          index: 4,
          key: "same",
          value: "Les champs :attribute et :other doivent être identiques.",
          value_type: "string"
        },
        %Entry{
          index: 5,
          key: "size.numeric",
          value: "La taille de la valeur de :attribute doit être :size.",
          value_type: "string"
        },
        %Entry{
          index: 6,
          key: "size.file",
          value: "La taille du fichier de :attribute doit être de :size kilobytes.",
          value_type: "string"
        },
        %Entry{
          index: 7,
          key: "size.string",
          value: "Le texte de :attribute doit contenir :size caractères.",
          value_type: "string"
        }
      ]
    end
  end
end
