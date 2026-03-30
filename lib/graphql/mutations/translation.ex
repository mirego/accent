defmodule Accent.GraphQL.Mutations.Translation do
  @moduledoc false
  use Absinthe.Schema.Notation

  import Accent.GraphQL.Helpers.Authorization

  alias Accent.GraphQL.Resolvers.Translation, as: TranslationResolver

  object :translation_mutations do
    field :correct_translation, :mutated_translation do
      arg(:id, non_null(:id))
      arg(:text, non_null(:string))

      resolve(translation_authorize(:correct_translation, &TranslationResolver.correct/3))
    end

    field :uncorrect_translation, :mutated_translation do
      arg(:id, non_null(:id))
      arg(:text, non_null(:string))

      resolve(translation_authorize(:uncorrect_translation, &TranslationResolver.uncorrect/3))
    end

    field :update_translation, :mutated_translation do
      arg(:id, non_null(:id))
      arg(:text, non_null(:string))

      resolve(translation_authorize(:update_translation, &TranslationResolver.update/3))
    end

    field :update_translation_settings, :mutated_translation do
      arg(:id, non_null(:id))
      arg(:plural, :boolean)
      arg(:locked, :boolean)
      arg(:placeholders, list_of(:string))
      arg(:file_index, :integer)
      arg(:file_comment, :string)
      arg(:value_type, :translation_value_type)
      arg(:source_translation_id, :id)

      resolve(translation_authorize(:update_translation_settings, &TranslationResolver.update_settings/3))
    end
  end
end
