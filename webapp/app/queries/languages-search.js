import gql from 'graphql-tag';

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
