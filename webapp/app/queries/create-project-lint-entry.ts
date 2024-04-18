import {gql} from '@apollo/client/core';

export default gql`
  mutation ProjectLintEntryCreate(
    $projectId: ID!
    $checkIds: [ID!]!
    $type: LintEntryType!
    $value: String
  ) {
    createProjectLintEntry(
      checkIds: $checkIds
      type: $type
      value: $value
      projectId: $projectId
    ) {
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
