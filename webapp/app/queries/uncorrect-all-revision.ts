import { gql } from '@apollo/client/core';

export default gql`
  mutation UncorrectAll($revisionId: ID!) {
    uncorrectAllRevision(id: $revisionId) {
      revision {
        id
        conflictsCount
        reviewedCount
      }

      errors
    }
  }
`;
