import {gql} from '@apollo/client/core';

export default gql`
  mutation IntegrationExecute(
    $integrationId: ID!
    $azureStorageContainer: ProjectIntegrationExecuteAzureStorageContainerInput
    $awsS3: ProjectIntegrationExecuteAwsS3Input
  ) {
    executeProjectIntegration(
      id: $integrationId
      azureStorageContainer: $azureStorageContainer
      awsS3: $awsS3
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
