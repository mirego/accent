import gql from 'npm:graphql-tag';

export default gql`
query Translation($projectId: ID!, $translationId: ID!) {
  viewer {
    project(id: $projectId) {
      id
      translation(id: $translationId) {
        id
        key
        isConflicted
        isRemoved
        valueType
        plural
        commentsCount
        correctedText
        conflictedText
        updatedAt

        sourceTranslation {
          id
        }

        masterTranslation {
          id
          placeholders
        }

        version {
          id
          tag
        }

        revision {
          id

          language {
            id
            name
          }
        }
      }
    }
  }
}
`;
