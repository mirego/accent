import { gql } from '@apollo/client/core';

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
          markedAsDeleted
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
