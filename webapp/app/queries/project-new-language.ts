import gql from 'graphql-tag';

export default gql`
  query ProjectNewLanguage($projectId: ID!) {
    languages {
      entries {
        id
        name
        slug
      }
    }

    viewer {
      project(id: $projectId) {
        id
        revisions {
          id
          name
          slug
          isMaster
          insertedAt

          language {
            id
            slug
            name
          }
        }
      }
    }
  }
`;
