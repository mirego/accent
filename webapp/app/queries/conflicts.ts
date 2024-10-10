import {gql} from '@apollo/client/core';

export default gql`
  query Conflicts(
    $projectId: ID!
    $query: String
    $page: Int
    $document: ID
    $relatedRevisions: [ID!]
    $version: ID
    $isTextEmpty: Boolean
    $isTextNotEmpty: Boolean
    $isAddedLastSync: Boolean
    $isCommentedOn: Boolean
    $isTranslated: Boolean
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

        prompts {
          id
          quickAccess
          name
        }

        revisions {
          id
          isMaster
          slug
          name

          language {
            id
            slug
            name
          }
        }

        groupedTranslations(
          query: $query
          page: $page
          pageSize: 20
          document: $document
          version: $version
          relatedRevisions: $relatedRevisions
          isConflicted: true
          isTextEmpty: $isTextEmpty
          isTextNotEmpty: $isTextNotEmpty
          isAddedLastSync: $isAddedLastSync
          isTranslated: $isTranslated
          isCommentedOn: $isCommentedOn
        ) {
          meta {
            totalEntries
            totalPages
            currentPage
            nextPage
            previousPage
          }

          revisions {
            id
            isMaster
            slug
            name

            language {
              id
              slug
              name
            }
          }

          entries {
            key
            document {
              id
              path
            }

            translations {
              id
              key
              conflictedText
              correctedText
              valueType
              isConflicted
              isTranslated

              lintMessages {
                text
                check
                message
                replacement {
                  value
                  label
                }
              }

              revision {
                id
                isMaster
                slug
                name
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
    }
  }
`;
