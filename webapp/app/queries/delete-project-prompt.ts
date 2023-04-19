import gql from 'graphql-tag';

export interface DeleteProjectPromptVariables {
  promptId: string;
}

export interface DeleteProjectPromptResponse {
  prompt: {
    id: string;
  };

  errors: any;
}

export default gql`
  mutation ProjectPromptDelete($promptId: ID!) {
    deleteProjectPrompt(id: $promptId) {
      prompt {
        id
      }

      errors
    }
  }
`;
