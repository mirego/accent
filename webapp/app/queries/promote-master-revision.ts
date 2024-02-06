import { gql } from '@apollo/client/core';

export default gql`
  mutation RevisionMasterPromote($revisionId: ID!) {
    promoteRevisionMaster(id: $revisionId) {
      revision {
        id
      }

      errors
    }
  }
`;
