import gql from 'npm:graphql-tag';

export default gql`
  query ProjectEdit($projectId: ID!) {
    viewer {
      project(id: $projectId) {
        id
        name
        mainColor
        isFileOperationsLocked
      }
    }
  }
`;
