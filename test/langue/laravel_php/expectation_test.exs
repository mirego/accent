defmodule LangueTest.Formatter.LaravelPhp.Expectation do
  alias Langue.Entry

  defmodule ParsesDoubleQuotations do
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
        %Entry{comment: "", index: 1, key: "required", value: "Le champ :attribute est obligatoire."},
        %Entry{comment: "", index: 2, key: "required_if", value: "Le champ :attribute est obligatoire quand la valeur de :other est :value."},
        %Entry{comment: "", index: 3, key: "required_with", value: "Le champ :attribute est obligatoire quand :values est présent."},
        %Entry{comment: "", index: 4, key: "same", value: "Les champs :attribute et :other doivent être identiques."},
        %Entry{comment: "", index: 5, key: "size.numeric", value: "La taille de la valeur de :attribute doit être :size."},
        %Entry{comment: "", index: 6, key: "size.file", value: "La taille du fichier de :attribute doit être de :size kilobytes."},
        %Entry{comment: "", index: 7, key: "size.string", value: "Le texte de :attribute doit contenir :size caractères."}
      ]
    end
  end
end
