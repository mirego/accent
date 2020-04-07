import gql from 'graphql-tag';

export default gql`
  mutation CollaboratorCreate($role: Role!, $email: String!, $projectId: ID!) {
    createCollaborator(role: $role, email: $email, projectId: $projectId) {
      collaborator {
        id
      }

      errors
    }
  }
`;
