import gql from 'graphql-tag';

export interface CreateApiTokenVariables {
  name: string;
  projectId: string;
  pictureUrl: string;
  permissions: string[];
}

export interface CreateApiTokenResponse {
  apiToken: {
    id: string;
  };

  errors: any;
}

export default gql`
  mutation ApiTokenCreate(
    $name: String!
    $pictureUrl: String
    $projectId: ID!
    $permissions: [String!]
  ) {
    createApiToken(
      name: $name
      pictureUrl: $pictureUrl
      permissions: $permissions
      projectId: $projectId
    ) {
      apiToken {
        id
      }

      errors
    }
  }
`;
