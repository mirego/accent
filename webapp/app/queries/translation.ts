import gql from 'graphql-tag';

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
          updatedAt
          fileComment

          lintMessages {
            text
            check
            replacement {
              value
              label
            }
          }

          document {
            id
            path
          }

          sourceTranslation {
            id
          }

          masterTranslation {
            id
            correctedText
            placeholders
          }

          relatedTranslations {
            id
            key
            correctedText
            isConflicted
            isRemoved
            updatedAt
            valueType

            lintMessages {
              text
              check
              replacement {
                value
                label
              }
            }

            revision {
              id
              name
              slug
              isMaster
              rtl

              language {
                id
                slug
                name
                rtl
              }
            }
          }

          version {
            id
            tag
          }

          revision {
            id
            name
            isMaster
            slug
            rtl

            language {
              id
              slug
              name
              rtl
            }
          }
        }
      }
    }
  }
`;
