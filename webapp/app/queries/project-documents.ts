import gql from 'graphql-tag';

export default gql`
  query ProjectDocuments($projectId: ID!, $page: Int) {
    viewer {
      project(id: $projectId) {
        id

        revisions {
          id
          language {
            id
            name
          }
        }

        documents(page: $page) {
          meta {
            totalEntries
            totalPages
            currentPage
            nextPage
            previousPage
          }
          entries {
            id
            path
            format
            conflictsCount
            reviewedCount
            translationsCount
          }
        }
      }
    }
  }
`;
