import gql from 'graphql-tag';

export default gql`
  mutation CorrectAll($revisionId: ID!) {
    correctAllRevision(id: $revisionId) {
      revision {
        id
        conflictsCount
        reviewedCount
      }

      errors
    }
  }
`;
