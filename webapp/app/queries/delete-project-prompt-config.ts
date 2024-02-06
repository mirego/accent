import { gql } from '@apollo/client/core';

export interface DeleteProjectPromptConfigVariables {
  projectId: string;
}

export interface DeleteProjectPromptConfigResponse {
  project: {
    id: string;
  };

  errors: any;
}

export default gql`
  mutation ProjectPromptConfigDelete($projectId: ID!) {
    deleteProjectPromptConfig(projectId: $projectId) {
      project {
        id
      }

      errors
    }
  }
`;
