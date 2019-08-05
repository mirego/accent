import gql from 'graphql-tag';

export default gql`
  query Project($projectId: ID!, $revisionId: ID) {
    viewer {
      project(id: $projectId) {
        id
        name
        mainColor

        viewerPermissions

        revisions {
          id
          isMaster

          language {
            id
            slug
            name
          }
        }

        revision(id: $revisionId) {
          id
          translations(pageSize: 10000) {
            entries {
              id
              key
              correctedText
              isConflicted
              document {
                id
                path
              }
            }
          }
        }
      }
    }
  }
`;
