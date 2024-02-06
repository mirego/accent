import { gql } from '@apollo/client/core';

export default gql`
  mutation TranslationCommentsSubscriptionDelete(
    $translationCommentsSubscripitionId: ID!
  ) {
    deleteTranslationCommentsSubscription(
      id: $translationCommentsSubscripitionId
    ) {
      translationCommentsSubscription {
        id
      }

      errors
    }
  }
`;
