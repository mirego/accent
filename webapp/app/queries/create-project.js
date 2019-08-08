import gql from 'npm:graphql-tag';

export default gql`
  mutation ProjectCreate(
    $name: String!
    $mainColor: String!
    $languageId: ID!
  ) {
    createProject(name: $name, mainColor: $mainColor, languageId: $languageId) {
      project {
        id
      }

      errors
    }
  }
`;
