import gql from 'graphql-tag';

export default gql`
  mutation ProjectDelete($projectId: ID!) {
    deleteProject(id: $projectId) {
      project {
        id
      }

      errors
    }
  }
`;
