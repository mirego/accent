import gql from 'graphql-tag';

export default gql`
  query Translations($projectId: ID!, $translationId: ID!) {
    viewer {
      project(id: $projectId) {
        id

        prompts {
          id
          quickAccess
          name
        }

        translation(id: $translationId) {
          id

          editions {
            id
            key
            isConflicted
            isTranslated
            correctedText
            updatedAt
            commentsCount
            valueType
            lintMessages {
              text
              check
              offset
              length
              message
              replacement {
                value
                label
              }
            }

            version {
              id
              tag
            }

            revision {
              id
              slug
              rtl

              language {
                id
                slug
                rtl
              }
            }

            document {
              id
              path
            }
          }
        }
      }
    }
  }
`;
