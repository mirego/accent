import gql from 'graphql-tag';

export default gql`
  query Conflicts(
    $projectId: ID!
    $revisionId: ID!
    $query: String
    $page: Int
    $reference: ID
    $document: ID
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

        revision(id: $revisionId) {
          id
          translations(
            query: $query
            page: $page
            document: $document
            referenceRevision: $reference
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
              relatedTranslation {
                id
                correctedText
                updatedAt
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
