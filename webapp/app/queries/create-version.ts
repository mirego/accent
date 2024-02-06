import {gql} from '@apollo/client/core';

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
