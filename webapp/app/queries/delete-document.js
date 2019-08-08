import gql from 'npm:graphql-tag';

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
