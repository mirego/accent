import { gql } from '@apollo/client/core';

export interface CreateProjectVariables {
  name: string;
  mainColor: string;
  logo: string;
  languageId: string;
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
