import {gql} from '@apollo/client/core';

export default gql`
  mutation FixLintTranslations(
    $projectId: ID!
    $revisionId: ID
    $checkIds: [ID!]
    $check: LintCheck
    $query: String
  ) {
    fixLintTranslations(
      id: $projectId
      revisionId: $revisionId
      checkIds: $checkIds
      check: $check
      query: $query
    ) {
      errors
    }
  }
`;
