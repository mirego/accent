import { gql } from '@apollo/client/core';

export default gql`
  mutation PromptUpdate(
    $id: ID!
    $name: String
    $quickAccess: String
    $content: String!
  ) {
    updateProjectPrompt(
      id: $id
      name: $name
      quickAccess: $quickAccess
      content: $content
    ) {
      prompt {
        id
        name
        quickAccess
        displayName
        content
      }

      errors
    }
  }
`;
