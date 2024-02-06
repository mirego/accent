import {gql} from '@apollo/client/core';

export default gql`
  mutation TextPromptImprove($promptId: ID!, $text: String!) {
    improveTextWithPrompt(id: $promptId, text: $text) {
      text

      errors
    }
  }
`;
