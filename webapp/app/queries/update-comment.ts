import { gql } from '@apollo/client/core';

export default gql`
  mutation CommentUpdate($commentId: ID!, $text: String!) {
    updateComment(id: $commentId, text: $text) {
      comment {
        id
        text
      }

      errors
    }
  }
`;
