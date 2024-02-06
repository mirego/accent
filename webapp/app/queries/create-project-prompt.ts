import {gql} from '@apollo/client/core';

export interface CreatePromptResponse {
  prompt: {
    id: string;
    name: string | null;
    displayName: string;
    content: string;
    quickAccess: string | null;
  };

  errors: any;
}

export default gql`
  mutation PromptCreate(
    $id: ID!
    $name: String
    $quickAccess: String
    $content: String!
  ) {
    createProjectPrompt(
      projectId: $id
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
