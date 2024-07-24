import {gql} from '@apollo/client/core';

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
