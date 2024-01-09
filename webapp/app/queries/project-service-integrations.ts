import gql from 'graphql-tag';

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

          ... on ProjectIntegrationGithub {
            data {
              id
              repository
              defaultRef
            }
          }

          ... on ProjectIntegrationCdnAzure {
            data {
              id
              accountName
              containerName
            }
          }
        }
      }
    }
  }
`;
