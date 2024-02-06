import { gql } from '@apollo/client/core';

export default gql`
  mutation ProjectUpdate(
    $projectId: ID!
    $name: String!
    $mainColor: String!
    $logo: String
    $isFileOperationsLocked: Boolean
  ) {
    updateProject(
      id: $projectId
      name: $name
      mainColor: $mainColor
      logo: $logo
      isFileOperationsLocked: $isFileOperationsLocked
    ) {
      project {
        id
        name
        isFileOperationsLocked
      }

      errors
    }
  }
`;
