import gql from 'graphql-tag';

export default gql`
  query Lint(
    $projectId: ID!
    $revisionId: ID
    $ruleIds: [ID!]
    $query: String
  ) {
    viewer {
      project(id: $projectId) {
        id

        documents {
          entries {
            id
            path
            format
          }
        }

        versions {
          entries {
            id
            tag
          }
        }

        lintTranslations(
          revisionId: $revisionId
          ruleIds: $ruleIds
          query: $query
        ) {
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
            message
            offset
            length
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
