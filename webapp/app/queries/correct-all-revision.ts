import {gql} from '@apollo/client/core';

export default gql`
  mutation CorrectAll($revisionId: ID!, $documentId: ID, $versionId: ID) {
    correctAllRevision(
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
