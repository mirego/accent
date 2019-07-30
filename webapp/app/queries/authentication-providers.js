import gql from 'npm:graphql-tag';

export default gql`
  query AuthenticationProviders {
    authenticationProviders {
      id
    }
  }
`;
