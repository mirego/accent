import gql from 'graphql-tag';

export default gql`
  query ProjectVersions($projectId: ID!, $page: Int) {
    viewer {
      project(id: $projectId) {
        id

        documents {
          entries {
            id
            path
            format
            translationsCount
          }
        }

        versions(page: $page) {
          meta {
            totalEntries
            totalPages
            currentPage
            nextPage
            previousPage
          }
          entries {
            id
            name
            tag
            insertedAt

            user {
              id
              fullname
            }
          }
        }
      }
    }
  }
`;
