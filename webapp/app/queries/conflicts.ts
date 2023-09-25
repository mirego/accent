import gql from 'graphql-tag';

export default gql`
  query Conflicts(
    $projectId: ID!
    $revisionId: ID!
    $query: String
    $page: Int
    $document: ID
    $version: ID
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

        revision(id: $revisionId) {
          id

          translations(
            query: $query
            page: $page
            pageSize: 20
            document: $document
            version: $version
            isConflicted: true
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
              conflictedText
              correctedText
              valueType

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

              relatedTranslations {
                id
                correctedText
                isConflicted
                revision {
                  id
                  isMaster
                  name
                  slug
                  rtl

                  language {
                    id
                    name
                    slug
                    rtl
                  }
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
  }
`;
