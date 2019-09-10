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
            context {
              text
              offset
              length
            }
            rule {
              id
              description
            }
            replacements {
              value
            }
          }
        }
      }
    }
  }
`;
