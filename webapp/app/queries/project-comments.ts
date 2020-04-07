import gql from 'graphql-tag';

export default gql`
  query ProjectComments($projectId: ID!, $page: Int) {
    viewer {
      project(id: $projectId) {
        id
        comments(page: $page) {
          meta {
            totalEntries
            totalPages
            currentPage
            nextPage
            previousPage
          }
          entries {
            id
            text
            insertedAt
            user {
              id
              email
              fullname
              pictureUrl
            }
            translation {
              id
              key
              document {
                id
                path
              }
              revision {
                id
                language {
                  id
                  name
                }
              }
            }
          }
        }
      }
    }
  }
`;
