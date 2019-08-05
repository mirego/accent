import gql from 'graphql-tag';

export default gql`
  query Dashboard($projectId: ID!) {
    viewer {
      project(id: $projectId) {
        id
        name
        lastSyncedAt

        documents {
          entries {
            id
          }
        }

        revisions {
          id
          conflictsCount
          reviewedCount
          translationsCount
          isMaster
          name
          language {
            id
            name
          }
        }

        activities(pageSize: 7) {
          entries {
            id
            action
            insertedAt
            updatedAt
            isBatch
            isRollbacked
            activityType
            text

            stats {
              action
              count
            }

            user {
              id
              pictureUrl
              fullname
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
