import {gql} from '@apollo/client/core';

export default gql`
  mutation ProjectLintEntryUpdate(
    $id: ID!
    $checkIds: [ID!]
    $type: LintEntryType
    $value: String
  ) {
    updateProjectLintEntry(
      id: $id
      checkIds: $checkIds
      type: $type
      value: $value
    ) {
      projectLintEntry: result {
        id
        checkIds
        type
        value
      }

      successful
      errors: messages {
        code
        field
      }
    }
  }
`;
