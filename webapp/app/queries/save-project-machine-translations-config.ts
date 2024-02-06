import {gql} from '@apollo/client/core';

export interface SaveProjectMachineTranslationsConfigVariables {
  projectId: string;
  provider: string;
  configKey: string;
  enabledActions: string[];
  usePlatform: boolean;
}

export interface SaveProjectMachineTranslationsConfigResponse {
  project: {
    id: string;
  };

  errors: any;
}

export default gql`
  mutation ProjectMachineTranslationsConfigSave(
    $provider: String!
    $configKey: String
    $usePlatform: Boolean!
    $enabledActions: [String!]!
    $projectId: ID!
  ) {
    saveProjectMachineTranslationsConfig(
      provider: $provider
      configKey: $configKey
      usePlatform: $usePlatform
      enabledActions: $enabledActions
      projectId: $projectId
    ) {
      project {
        id
      }

      errors
    }
  }
`;
