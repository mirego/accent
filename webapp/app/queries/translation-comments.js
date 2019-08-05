import gql from 'graphql-tag';

export default gql`
  query TranslationComments($projectId: ID!, $translationId: ID!, $page: Int) {
    viewer {
      project(id: $projectId) {
        id

        collaborators {
          id
          email
          isPending
          role

          user {
            id
            fullname
            email
          }
        }

        translation(id: $translationId) {
          id
          commentsCount
          isRemoved

          commentsSubscriptions {
            id
            user {
              id
              email
              fullname
            }
          }

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
            }
          }
        }
      }
    }
  }
`;
