import gql from 'graphql-tag';

export default gql`
  query AuthenticationProviders {
    authenticationProviders {
      id
    }
  }
`;
