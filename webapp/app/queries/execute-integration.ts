import gql from 'graphql-tag';

export default gql`
  mutation IntegrationExecute(
    $integrationId: ID!
    $azureStorageContainer: ProjectIntegrationExecuteAzureStorageContainerInput
  ) {
    executeProjectIntegration(
      id: $integrationId
      azureStorageContainer: $azureStorageContainer
    ) {
      projectIntegration: result {
        id
      }

      successful
      errors: messages {
        code
        field
      }
    }
  }
`;
