import gql from 'graphql-tag';

export default gql`
  query LintTranslation($projectId: ID!, $text: String, $translationId: ID!) {
    viewer {
      project(id: $projectId) {
        id
        translation(id: $translationId) {
          id
          key
          text: correctedText

          lintMessages(text: $text) {
            text
            message
            check
            offset
            length
            replacement {
              value
              label
            }
          }
        }
      }
    }
  }
`;
