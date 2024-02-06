import {gql} from '@apollo/client/core';

export default gql`
  query ProjectEdit($projectId: ID!) {
    viewer {
      project(id: $projectId) {
        id
        name
        mainColor
        logo
        isFileOperationsLocked
      }
    }
  }
`;
