import gql from 'graphql-tag';

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
