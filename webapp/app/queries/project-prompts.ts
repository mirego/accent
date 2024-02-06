import {gql} from '@apollo/client/core';

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
