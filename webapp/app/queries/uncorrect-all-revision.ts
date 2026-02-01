import {gql} from '@apollo/client/core';

export default gql`
  mutation UncorrectAll($revisionId: ID!, $documentId: ID, $versionId: ID) {
    uncorrectAllRevision(
      id: $revisionId
      documentId: $documentId
      versionId: $versionId
    ) {
      revision {
        id
        conflictsCount
        reviewedCount
      }

      errors
    }
  }
`;
