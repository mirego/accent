import {gql} from '@apollo/client/core';

export default gql`
  mutation CommentCreate($translationId: ID!, $text: String!) {
    createComment(id: $translationId, text: $text) {
      comment {
        id
        text
      }

      errors
    }
  }
`;
