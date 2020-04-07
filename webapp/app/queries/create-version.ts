import gql from 'graphql-tag';

export default gql`
  mutation VersionCreate($name: String!, $tag: String!, $projectId: ID!) {
    createVersion(name: $name, tag: $tag, projectId: $projectId) {
      version {
        id
      }

      errors
    }
  }
`;
