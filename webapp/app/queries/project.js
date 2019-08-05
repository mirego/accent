import gql from 'graphql-tag';

export default gql`
  query Project($projectId: ID!) {
    roles {
      slug
    }

    documentFormats {
      slug
      name
      extension
    }

    viewer {
      project(id: $projectId) {
        id
        name
        mainColor

        viewerPermissions

        documents {
          entries {
            id
            path
            format
          }
        }

        revisions {
          id
          name
          isMaster
          translationsCount
          conflictsCount

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
