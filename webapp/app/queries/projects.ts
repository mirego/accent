import gql from 'graphql-tag';

export default gql`
  query Projects($query: String, $page: Int) {
    languages {
      entries {
        id
        name
        slug
      }
    }

    viewer {
      permissions

      projects(query: $query, page: $page) {
        meta {
          totalEntries
          totalPages
          currentPage
          nextPage
          previousPage
        }
        entries {
          id
          name
          lastSyncedAt
          mainColor
          logo
          translationsCount
          conflictsCount
        }
      }
    }
  }
`;
