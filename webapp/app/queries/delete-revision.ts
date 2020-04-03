import gql from 'graphql-tag';

export default gql`
  mutation RevisionDelete($revisionId: ID!) {
    deleteRevision(id: $revisionId) {
      revision {
        id
      }

      errors
    }
  }
`;
