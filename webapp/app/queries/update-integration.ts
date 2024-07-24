import {gql} from '@apollo/client/core';

export default gql`
  mutation IntegrationUpdate(
    $events: [ProjectIntegrationEvent!]
    $service: ProjectIntegrationService!
    $integrationId: ID!
    $data: ProjectIntegrationDataInput!
  ) {
    updateProjectIntegration(
      events: $events
      service: $service
      id: $integrationId
      data: $data
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
