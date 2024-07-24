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
            events
            data {
              id
              url
            }
          }

          ... on ProjectIntegrationDiscord {
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
