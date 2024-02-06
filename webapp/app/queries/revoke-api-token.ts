import { gql } from '@apollo/client/core';

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
