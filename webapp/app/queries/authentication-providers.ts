import { gql } from '@apollo/client/core';

export default gql`
  query AuthenticationProviders {
    authenticationProviders {
      id
    }
  }
`;
