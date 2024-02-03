import gql from 'graphql-tag';

export default gql`
  mutation TranslationUncorrect($translationId: ID!, $text: String!) {
    uncorrectTranslation(id: $translationId, text: $text) {
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
