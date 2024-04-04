import {gql} from '@apollo/client/core';

export default gql`
  query Projects($query: String, $page: Int, $nodeIds: [ID!]) {
    languages {
      entries {
        id
        name
        slug
      }
    }

    viewer {
      permissions

      projects(query: $query, page: $page, nodeIds: $nodeIds) {
        meta {
          totalEntries
          totalPages
          currentPage
          nextPage
          previousPage
        }

        nodes {
          id
          name
          mainColor
          logo
        }

        entries {
          id
          name
          lastSyncedAt
          mainColor
          logo
        }
      }
    }
  }
`;
