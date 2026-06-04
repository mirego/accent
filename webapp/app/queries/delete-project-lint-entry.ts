import {gql} from '@apollo/client/core';

export default gql`
  mutation ProjectLintEntryDelete($id: ID!) {
    deleteProjectLintEntry(id: $id) {
      projectLintEntry: result {
        id
      }

      successful
      errors: messages {
        code
        field
      }
    }
  }
`;
