import gql from 'graphql-tag';

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
