import gql from 'graphql-tag';

export default gql`
  query Translations(
    $projectId: ID!
    $revisionId: ID
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
            pageSize: 10000
            document: $document
            version: $version
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
            }
          }
        }
      }
    }
  }
`;
