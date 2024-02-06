import {gql} from '@apollo/client/core';

export default gql`
  mutation CollaboratorDelete($collaboratorId: ID!) {
    deleteCollaborator(id: $collaboratorId) {
      collaborator {
        id
      }

      errors
    }
  }
`;
