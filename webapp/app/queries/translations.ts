import gql from 'graphql-tag';

export default gql`
  query Translations(
    $projectId: ID!
    $revisionId: ID!
    $query: String
    $page: Int
    $document: ID
    $version: ID
    $isTextEmpty: Boolean
    $isTextNotEmpty: Boolean
    $isAddedLastSync: Boolean
    $isCommentedOn: Boolean
    $isConflicted: Boolean
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

        revision(id: $revisionId) {
          id
          translations(
            query: $query
            page: $page
            document: $document
            version: $version
            isTextEmpty: $isTextEmpty
            isTextNotEmpty: $isTextNotEmpty
            isAddedLastSync: $isAddedLastSync
            isConflicted: $isConflicted
            isCommentedOn: $isCommentedOn
          ) {
            meta {
              totalEntries
              totalPages
              currentPage
              nextPage
              previousPage
            }
            entries {
              id
              key
              isConflicted
              correctedText
              updatedAt
              commentsCount
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
  }
`;
