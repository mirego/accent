import gql from 'graphql-tag';

export default gql`
  query LintTranslation($projectId: ID!, $text: String, $translationId: ID!) {
    viewer {
      project(id: $projectId) {
        id
        translation(id: $translationId) {
          id
          lintMessages(text: $text) {
            text
            check
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
