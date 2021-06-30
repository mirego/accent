import gql from 'graphql-tag';

export default gql`
  query Lint($projectId: ID!) {
    viewer {
      project(id: $projectId) {
        id

        lintTranslations {
          translation {
            id
            key
            text: correctedText

            document {
              id
              path
            }
          }

          messages {
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
