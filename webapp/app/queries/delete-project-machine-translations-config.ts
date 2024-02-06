import { gql } from '@apollo/client/core';

export interface DeleteProjectMachineTranslationsConfigVariables {
  projectId: string;
}

export interface DeleteProjectMachineTranslationsConfigResponse {
  project: {
    id: string;
  };

  errors: any;
}

export default gql`
  mutation ProjectMachineTranslationsConfigDelete($projectId: ID!) {
    deleteProjectMachineTranslationsConfig(projectId: $projectId) {
      project {
        id
      }

      errors
    }
  }
`;
