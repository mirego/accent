import gql from 'graphql-tag';

export default gql`
  query RelatedTranslations($projectId: ID!, $translationId: ID!) {
    viewer {
      project(id: $projectId) {
        id
        translation(id: $translationId) {
          id
          relatedTranslations {
            id
            key
            correctedText
            isConflicted
            isRemoved
            updatedAt

            revision {
              id
              name

              language {
                id
                name
              }
            }
          }
        }
      }
    }
  }
`;
