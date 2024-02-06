import { gql } from '@apollo/client/core';

export default gql`
  mutation IntegrationCreate(
    $events: [ProjectIntegrationEvent!]
    $service: ProjectIntegrationService!
    $projectId: ID!
    $data: ProjectIntegrationDataInput!
  ) {
    createProjectIntegration(
      events: $events
      service: $service
      projectId: $projectId
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
