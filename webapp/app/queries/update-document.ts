import {gql} from '@apollo/client/core';

export default gql`
  mutation DocumentUpdate($documentId: ID!, $path: String!) {
    updateDocument(id: $documentId, path: $path) {
      document {
        id
        path
      }

      errors
    }
  }
`;
