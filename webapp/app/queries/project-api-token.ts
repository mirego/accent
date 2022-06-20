import gql from 'graphql-tag';

export default gql`
  query ProjectApiToken($projectId: ID!) {
    viewer {
      accessToken

      project(id: $projectId) {
        id
        name
        accessToken
      }
    }
  }
`;
