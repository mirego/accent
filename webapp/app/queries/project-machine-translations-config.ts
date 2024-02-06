import {gql} from '@apollo/client/core';

export default gql`
  query ProjectMachineTranslationsConfig($projectId: ID!) {
    viewer {
      project(id: $projectId) {
        id
        machineTranslationsConfig {
          provider
          usePlatform
          enabledActions
          useConfigKey
        }
      }
    }
  }
`;
