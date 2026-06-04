import {gql} from '@apollo/client/core';

export default gql`
  query ProjectLintEntries($projectId: ID!, $page: Int, $pageSize: Int) {
    viewer {
      project(id: $projectId) {
        id
        lintEntries(page: $page, pageSize: $pageSize) {
          meta {
            totalEntries
            totalPages
            currentPage
            nextPage
            previousPage
          }
          entries {
            id
            checkIds
            type
            value
          }
        }
      }
    }
  }
`;
