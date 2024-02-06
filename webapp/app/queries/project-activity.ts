import { gql } from '@apollo/client/core';

export default gql`
  query ProjectActivity($projectId: ID!, $activityId: ID!) {
    viewer {
      project(id: $projectId) {
        id

        activity(id: $activityId) {
          ...activityFields

          isBatch
          isRollbacked
          activityType

          document {
            id
            path
            format
          }

          previousTranslation {
            proposedText
            text
            isConflicted
            isRemoved
            valueType
          }

          translation {
            id
            key
            correctedText
            isConflicted
            isRemoved
            document {
              id
              path
            }
          }

          version {
            id
            tag
          }

          batchOperation {
            ...activityFields
          }

          rollbackedOperation {
            ...activityFields
          }

          rollbackOperation {
            ...activityFields
          }
        }
      }
    }
  }

  fragment activityFields on Activity {
    id
    action
    text
    insertedAt
    updatedAt
    valueType

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

    stats {
      action
      count
    }

    document {
      id
      path
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
  }
`;
