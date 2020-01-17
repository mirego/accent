import gql from 'graphql-tag';

export interface ProjectDashboardQueryVariables {
  projectId: string;
}

export interface ProjectDashboardQueryResponse {
  viewer: {
    project: {
      id: string;
      name: string;
      lastSyncedAt: string;

      documents: {
        entries: Array<{
          id: string;
        }>;
      };

      revisions: Array<{
        id: string;
        conflictsCount: number;
        reviewedCount: number;
        translationsCount: number;
        isMaster: boolean;
        name: string;
        language: {
          id: string;
          name: string;
        };
      }>;

      activities: {
        entries: Array<{
          id: string;
          action: string;
          insertedAt: string;
          updatedAt: string;
          isBatch: boolean;
          isRollbacked: boolean;
          activityType: string;
          text: string;

          stats: {
            action: string;
            count: number;
          };

          user: {
            id: string;
            pictureUrl: string;
            fullname: string;
            isBot: boolean;
          };

          document: {
            id: string;
            path: string;
          };

          translation: {
            id: string;
            key: string;
            correctedText: string;
            isRemoved: boolean;
          };

          revision: {
            id: string;
            name: string;

            language: {
              id: string;
              name: string;
            };
          };

          version: {
            id: string;
            tag: string;
          };

          rollbackedOperation: {
            id: string;
            action: string;
            text: string;

            user: {
              id: string;
              fullname: string;
              isBot: boolean;
            };

            translation: {
              id: string;
              key: string;
            };

            document: {
              id: string;
              path: string;
            };
          };
        }>;
      };
    };
  };
}

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
