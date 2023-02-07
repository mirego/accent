import gql from 'graphql-tag';

export interface SaveProjectMachineTranslationsConfigVariables {
  name: string;
  projectId: string;
  pictureUrl: string;
  permissions: string[];
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
    $projectId: ID!
  ) {
    saveProjectMachineTranslationsConfig(
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
