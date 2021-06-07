import gql from 'graphql-tag';

export default gql`
  mutation RevisionCreate(
    $projectId: ID!
    $languageId: ID!
    $defaultNull: Boolean
  ) {
    createRevision(
      projectId: $projectId
      languageId: $languageId
      defaultNull: $defaultNull
    ) {
      revision {
        id
      }

      errors
    }
  }
`;
