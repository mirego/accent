import gql from 'graphql-tag';

export default gql`
  mutation IntegrationExecute(
    $integrationId: ID!
    $cdnAzure: ProjectIntegrationExecuteCdnAzureInput
  ) {
    executeProjectIntegration(id: $integrationId, cdnAzure: $cdnAzure) {
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
