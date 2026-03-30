import {gql} from '@apollo/client/core';

export default gql`
  mutation TranslationSettingsUpdate(
    $translationId: ID!
    $plural: Boolean
    $locked: Boolean
    $placeholders: [String]
    $fileIndex: Int
    $fileComment: String
    $valueType: TranslationValueType
    $sourceTranslationId: ID
  ) {
    updateTranslationSettings(
      id: $translationId
      plural: $plural
      locked: $locked
      placeholders: $placeholders
      fileIndex: $fileIndex
      fileComment: $fileComment
      valueType: $valueType
      sourceTranslationId: $sourceTranslationId
    ) {
      translation {
        id
        plural
        locked
        valueType
        placeholders
        fileIndex
        fileComment

        sourceTranslation {
          id
        }
      }

      errors
    }
  }
`;
