import gql from 'npm:graphql-tag';

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
