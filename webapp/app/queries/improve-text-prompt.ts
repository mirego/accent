import gql from 'graphql-tag';

export default gql`
  mutation TextPromptImprove($promptId: ID!, $text: String!) {
    improveTextWithPrompt(id: $promptId, text: $text) {
      text

      errors
    }
  }
`;
