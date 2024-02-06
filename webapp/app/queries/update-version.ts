import { gql } from '@apollo/client/core';

export default gql`
  mutation VersionUpdate($id: ID!, $name: String!, $tag: String!) {
    updateVersion(id: $id, name: $name, tag: $tag) {
      version {
        id
        name
        tag
      }

      errors
    }
  }
`;
