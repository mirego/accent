import {gql} from '@apollo/client/core';

export default gql`
  mutation VersionDelete($versionId: ID!) {
    deleteVersion(id: $versionId) {
      version {
        id
      }

      errors
    }
  }
`;
