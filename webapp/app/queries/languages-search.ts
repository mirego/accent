import {gql} from '@apollo/client/core';

export default gql`
  query LanguagesSearch($query: String!) {
    languages(query: $query) {
      entries {
        id
        name
        slug
      }
    }
  }
`;
