import {gql} from '@apollo/client/core';

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
              isMaster

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
