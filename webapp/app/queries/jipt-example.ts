import {gql} from '@apollo/client/core';

export default gql`
  query JIPTExample($projectId: ID!) {
    viewer {
      project(id: $projectId) {
        id
        name
        mainColor

        revision {
          id
          translations(pageSize: 1) {
            entries {
              id
              key
              document {
                id
                path
              }
            }
          }
        }
      }
    }
  }
`;
