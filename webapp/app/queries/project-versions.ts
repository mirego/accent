import {gql} from '@apollo/client/core';

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
            copyOnUpdateTranslation

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
