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
            lastExecutedAt
            events
            data {
              id
              url
            }
          }

          ... on ProjectIntegrationDiscord {
            lastExecutedAt
            events
            data {
              id
              url
            }
          }

          ... on ProjectIntegrationAwsS3 {
            lastExecutedAt
            data {
              id
              bucket
              pathPrefix
              region
              accessKeyId
            }
          }

          ... on ProjectIntegrationAzureStorageContainer {
            lastExecutedAt
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
