import {gql} from '@apollo/client/core';

export default gql`
  mutation VersionUpdate(
    $id: ID!
    $name: String!
    $tag: String!
    $copyOnUpdateTranslation: Boolean!
  ) {
    updateVersion(
      id: $id
      name: $name
      tag: $tag
      copyOnUpdateTranslation: $copyOnUpdateTranslation
    ) {
      version {
        id
        name
        tag
      }

      errors
    }
  }
`;
