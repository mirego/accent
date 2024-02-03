import gql from 'graphql-tag';

export interface RevokeApiTokenVariables {
  id: string;
}

export default gql`
  mutation ApiTokenRevoke($id: ID!) {
    revokeApiToken(id: $id) {
      apiToken {
        id
      }

      errors
    }
  }
`;
