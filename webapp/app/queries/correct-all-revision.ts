import { gql } from '@apollo/client/core';

export default gql`
  mutation CorrectAll($revisionId: ID!) {
    correctAllRevision(id: $revisionId) {
      revision {
        id
        conflictsCount
        reviewedCount
      }

      errors
    }
  }
`;
