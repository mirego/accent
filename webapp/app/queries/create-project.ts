import gql from 'graphql-tag';

export interface CreateProjectVariables {
  name: String;
  mainColor: String;
  logo: String;
  languageId: String;
}

export interface CreateProjectResponse {
  createProject: {
    project: {
      id: string;
    };

    errors: any;
  };
}

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
