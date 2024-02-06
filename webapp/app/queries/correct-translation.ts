import {gql} from '@apollo/client/core';

export default gql`
  mutation TranslationCorrect($translationId: ID!, $text: String!) {
    correctTranslation(id: $translationId, text: $text) {
      translation {
        id
        correctedText
        conflictedText
        isConflicted
        updatedAt
      }

      errors
    }
  }
`;
