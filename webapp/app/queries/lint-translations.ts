import {gql} from '@apollo/client/core';

export default gql`
  query Lint(
    $projectId: ID!
    $revisionId: ID
    $checkIds: [ID!]
    $check: LintCheck
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

        lintChecks(
          revisionId: $revisionId
          checkIds: $checkIds
          query: $query
        ) {
          check
          count
        }

        lintTranslations(
          revisionId: $revisionId
          checkIds: $checkIds
          check: $check
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
            details {
              spellingRuleId
              spellingRuleDescription
            }
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
