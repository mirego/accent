import {gql} from '@apollo/client/core';

export default gql`
  mutation VersionCreate(
    $name: String!
    $tag: String!
    $projectId: ID!
    $copyOnUpdateTranslation: Boolean!
  ) {
    createVersion(
      name: $name
      tag: $tag
      projectId: $projectId
      copyOnUpdateTranslation: $copyOnUpdateTranslation
    ) {
      version {
        id
      }

      errors
    }
  }
`;
