import { gql } from '@apollo/client/core';

export default gql`
  mutation DocumentDelete($documentId: ID!) {
    deleteDocument(id: $documentId) {
      document {
        id
      }

      errors
    }
  }
`;
