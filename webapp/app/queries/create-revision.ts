import gql from 'graphql-tag';

export default gql`
  mutation RevisionCreate($projectId: ID!, $languageId: ID!) {
    createRevision(projectId: $projectId, languageId: $languageId) {
      revision {
        id
      }

      errors
    }
  }
`;
