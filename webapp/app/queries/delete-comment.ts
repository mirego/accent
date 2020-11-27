import gql from 'graphql-tag';

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
