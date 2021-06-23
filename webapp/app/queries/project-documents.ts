import gql from 'graphql-tag';

export default gql`
  query ProjectDocuments($projectId: ID!, $page: Int) {
    viewer {
      project(id: $projectId) {
        id

        revisions {
          id
          name
          slug

          language {
            id
            name
            slug
          }
        }

        versions {
          entries {
            id
            tag
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
