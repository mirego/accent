import {gql} from '@apollo/client/core';

export default gql`
  mutation CorrectAll(
    $revisionId: ID!
    $documentId: ID
    $versionId: ID
    $fromVersionId: ID
  ) {
    correctAllRevision(
      id: $revisionId
      documentId: $documentId
      versionId: $versionId
      fromVersionId: $fromVersionId
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
