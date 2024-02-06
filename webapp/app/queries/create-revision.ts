import { gql } from '@apollo/client/core';

export default gql`
  mutation RevisionCreate(
    $projectId: ID!
    $languageId: ID!
    $defaultNull: Boolean
    $machineTranslationsEnabled: Boolean
  ) {
    createRevision(
      projectId: $projectId
      languageId: $languageId
      defaultNull: $defaultNull
      machineTranslationsEnabled: $machineTranslationsEnabled
    ) {
      revision {
        id
      }

      errors
    }
  }
`;
