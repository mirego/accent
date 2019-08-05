import gql from 'graphql-tag';

export default gql`
  query ProjectApiToken($projectId: ID!) {
    viewer {
      project(id: $projectId) {
        id
        name
        accessToken
      }
    }
  }
`;
