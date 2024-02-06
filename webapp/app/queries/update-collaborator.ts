import { gql } from '@apollo/client/core';

export default gql`
  mutation CollaboratorUpdate($collaboratorId: ID!, $role: Role!) {
    updateCollaborator(id: $collaboratorId, role: $role) {
      collaborator {
        id
        role
      }

      errors
    }
  }
`;
