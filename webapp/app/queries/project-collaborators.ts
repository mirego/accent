import {gql} from '@apollo/client/core';

export default gql`
  query ProjectCollaborators($projectId: ID!) {
    viewer {
      project(id: $projectId) {
        id
        name

        collaborators {
          id
          isPending
          email
          role
          insertedAt

          assigner {
            id
            fullname
          }

          user {
            isBot
            id
            fullname
            pictureUrl
            email
          }
        }
      }
    }
  }
`;
