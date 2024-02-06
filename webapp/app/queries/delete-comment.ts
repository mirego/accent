import { gql } from '@apollo/client/core';

export default gql`
  mutation CommentDelete($commentId: ID!) {
    deleteComment(id: $commentId) {
      comment {
        id
      }

      errors
    }
  }
`;
