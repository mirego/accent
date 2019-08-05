import gql from 'graphql-tag';

export default gql`
  mutation ProjectUpdate(
    $projectId: ID!
    $name: String!
    $mainColor: String!
    $isFileOperationsLocked: Boolean
  ) {
    updateProject(
      id: $projectId
      name: $name
      mainColor: $mainColor
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
