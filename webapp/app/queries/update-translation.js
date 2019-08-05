import gql from 'graphql-tag';

export default gql`
  mutation TranslationUpdate($translationId: ID!, $text: String!) {
    updateTranslation(id: $translationId, text: $text) {
      translation {
        id
        correctedText
        conflictedText
        valueType
        updatedAt
      }

      errors
    }
  }
`;
