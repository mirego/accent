import gql from 'graphql-tag';

export default gql`
  query ProjectMachineTranslationsConfig($projectId: ID!) {
    viewer {
      project(id: $projectId) {
        id
        machineTranslationsConfig {
          provider
          usePlatform
          useConfigKey
        }
      }
    }
  }
`;
