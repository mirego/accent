import gql from 'graphql-tag';

export default gql`
  query Lint($projectId: ID!) {
    viewer {
      project(id: $projectId) {
        id

        revisions {
          id
        }

        lintTranslations {
          translation {
            id
            key
            text: correctedText

            revision {
              id
              name
              slug

              language {
                id
                slug
                name
              }
            }

            document {
              id
              path
            }
          }

          messages {
            text
            check
            replacement {
              value
              label
            }
          }
        }
      }
    }
  }
`;
