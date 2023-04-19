import gql from 'graphql-tag';

export default gql`
  query ProjectPrompts($projectId: ID!) {
    viewer {
      project(id: $projectId) {
        id

        prompts {
          id
          name: displayName
        }
      }
    }
  }
`;
