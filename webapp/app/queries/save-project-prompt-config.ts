import gql from 'graphql-tag';

export interface SaveProjectPromptConfigVariables {
  projectId: string;
  provider: string;
  configKey: string;
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
    $projectId: ID!
  ) {
    saveProjectPromptConfig(
      provider: $provider
      configKey: $configKey
      projectId: $projectId
    ) {
      project {
        id
      }

      errors
    }
  }
`;
