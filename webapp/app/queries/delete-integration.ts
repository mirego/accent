import {gql} from '@apollo/client/core';

export default gql`
  mutation IntegrationDelete($integrationId: ID!) {
    deleteProjectIntegration(id: $integrationId) {
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
