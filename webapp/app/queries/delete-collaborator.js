import gql from 'npm:graphql-tag';

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
