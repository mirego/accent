import gql from 'graphql-tag';

export default gql`
  mutation RevisionUpdate($revisionId: ID!, $name: String, $slug: String) {
    updateRevision(id: $revisionId, name: $name, slug: $slug) {
      revision {
        id
        name
        slug
      }

      errors
    }
  }
`;
