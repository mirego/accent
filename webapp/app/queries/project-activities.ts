import {gql} from '@apollo/client/core';

export default gql`
  query ProjectActivities(
    $projectId: ID!
    $page: Int
    $userId: ID
    $versionId: ID
    $isBatch: Boolean
    $action: String
  ) {
    viewer {
      project(id: $projectId) {
        id
        isFileOperationsLocked

        versions {
          entries {
            id
            tag
          }
        }

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

        activities(
          page: $page
          userId: $userId
          versionId: $versionId
          isBatch: $isBatch
          action: $action
        ) {
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

            batchedOperations {
              id

              stats {
                action
                count
              }

              document {
                id
                path
              }
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
              document {
                id
                path
              }
            }

            revision {
              id
              name
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
