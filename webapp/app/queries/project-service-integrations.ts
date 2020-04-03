import gql from 'graphql-tag';

export default gql`
  query ProjectServiceIntegrations($projectId: ID!) {
    viewer {
      project(id: $projectId) {
        id
        name
        accessToken

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

          ... on ProjectIntegrationGitHub {
            data {
              id
              repository
              token
              defaultRef
            }
          }
        }
      }
    }
  }
`;
