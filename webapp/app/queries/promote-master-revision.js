import gql from 'npm:graphql-tag';

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
