import {gql} from '@apollo/client/core';

export interface SaveProjectPromptConfigVariables {
  projectId: string;
  provider: string;
  configKey: string;
  usePlatform: boolean;
}

export interface SaveProjectPromptConfigResponse {
  project: {
    id: string;
  };

  errors: any;
}

export default gql`
  mutation ProjectPromptConfigSave(
    $provider: String!
    $configKey: String
    $usePlatform: Boolean!
    $projectId: ID!
  ) {
    saveProjectPromptConfig(
      provider: $provider
      configKey: $configKey
      usePlatform: $usePlatform
      projectId: $projectId
    ) {
      project {
        id
      }

      errors
    }
  }
`;
