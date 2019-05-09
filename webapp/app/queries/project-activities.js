import gql from 'npm:graphql-tag';

export default gql`
query ProjectActivities($projectId: ID!, $page: Int, $userId: String, $isBatch: Boolean, $action: String) {
  viewer {
    project(id: $projectId) {
      id
      isFileOperationsLocked

      collaborators {
        id
        isPending
        role

        user {
          id
          fullname
          email
        }
      }

      activities(page: $page, userId: $userId, isBatch: $isBatch, action: $action) {
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
          updatedAt
          isBatch
          isRollbacked
          activityType
          valueType
          text

          stats {
            action
            count
          }

          user {
            id
            fullname
            pictureUrl
            isBot
          }

          document {
            id
            path
          }

          translation {
            id
            key
            correctedText
            isRemoved
          }

          revision {
            id
            language {
              id
              name
            }
          }

          version {
            id
            tag
          }

          rollbackedOperation {
            id
            action
            insertedAt
            text

            user {
              id
              fullname
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
`;
