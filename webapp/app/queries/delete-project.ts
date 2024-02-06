import { gql } from '@apollo/client/core';

export default gql`
  mutation ProjectDelete($projectId: ID!) {
    deleteProject(id: $projectId) {
      project {
        id
      }

      errors
    }
  }
`;
