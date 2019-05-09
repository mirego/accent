import gql from 'npm:graphql-tag';

export default gql`
mutation UncorrectAll($revisionId: ID!) {
  uncorrectAllRevision(id: $revisionId) {
    revision {
      id
      conflictsCount
      reviewedCount
    }

    errors
  }
}
`;
