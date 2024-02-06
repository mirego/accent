import { gql } from '@apollo/client/core';

export default gql`
  query ProjectApiToken($projectId: ID!) {
    viewer {
      accessToken

      project(id: $projectId) {
        id
        name

        apiTokens {
          id
          token
          insertedAt
          customPermissions
          user {
            id
            fullname
            pictureUrl
          }
        }
      }
    }
  }
`;
