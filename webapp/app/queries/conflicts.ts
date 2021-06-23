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

                language {
                  id
                  slug
                  name
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

                  language {
                    id
                    name
                    slug
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
