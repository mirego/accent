import {gql} from '@apollo/client/core';

export default gql`
  query ProjectServiceIntegrations($projectId: ID!) {
    viewer {
      project(id: $projectId) {
        id
        name

        integrations {
          id
          service

          ... on ProjectIntegrationSlack {
            lastIntegrationExecution {
              id
              state
              insertedAt
            }
            events
            data {
              id
              url
            }
          }

          ... on ProjectIntegrationDiscord {
            lastIntegrationExecution {
              id
              state
              insertedAt
            }
            events
            data {
              id
              url
            }
          }

          ... on ProjectIntegrationAwsS3 {
            lastIntegrationExecution {
              id
              state
              insertedAt
            }
            data {
              id
              bucket
              pathPrefix
              region
              accessKeyId
            }
          }

          ... on ProjectIntegrationAzureStorageContainer {
            lastIntegrationExecution {
              id
              state
              insertedAt
            }
            data {
              id
              sasBaseUrl
            }
          }
        }
      }
    }
  }
`;
