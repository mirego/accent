import gql from 'graphql-tag';

export default gql`
  query TranslationActivities(
    $projectId: ID!
    $translationId: ID!
    $page: Int
    $action: String
  ) {
    viewer {
      project(id: $projectId) {
        id
        isFileOperationsLocked

        translation(id: $translationId) {
          id
          activities(page: $page, action: $action) {
            meta {
              totalEntries
              totalPages
              currentPage
              nextPage
              previousPage
            }
            entries {
              id
              action
              insertedAt
              isBatch
              isRollbacked
              text
              valueType

              user {
                id
                fullname
                pictureUrl
                isBot
              }

              document {
                id
                path
                format
              }

              translation {
                id
                correctedText
                document {
                  id
                  path
                }
              }

              version {
                id
                tag
              }

              rollbackedOperation {
                id
                insertedAt
                action
                text

                user {
                  id
                  fullname
                  pictureUrl
                  isBot
                }

                translation {
                  id
                  key
                }

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
  }
`;
