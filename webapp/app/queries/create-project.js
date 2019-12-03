import gql from 'graphql-tag';

export default gql`
  mutation ProjectCreate(
    $name: String!
    $mainColor: String!
    $logo: String
    $languageId: ID!
  ) {
    createProject(
      name: $name
      mainColor: $mainColor
      logo: $logo
      languageId: $languageId
    ) {
      project {
        id
      }

      errors
    }
  }
`;
