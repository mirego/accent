import { gql } from '@apollo/client/core';

export default gql`
  mutation TranslationCommentsSubscriptionCreate(
    $translationId: ID!
    $userId: ID!
  ) {
    createTranslationCommentsSubscription(
      translationId: $translationId
      userId: $userId
    ) {
      translationCommentsSubscription {
        id
      }

      errors
    }
  }
`;
