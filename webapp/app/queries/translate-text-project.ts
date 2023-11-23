import gql from 'graphql-tag';

export default gql`
  query TranslateTextProject(
    $projectId: ID!
    $text: String!
    $sourceLanguageSlug: String
    $targetLanguageSlug: String!
  ) {
    viewer {
      project(id: $projectId) {
        id
        translatedText(
          text: $text
          sourceLanguageSlug: $sourceLanguageSlug
          targetLanguageSlug: $targetLanguageSlug
        ) {
          error
          text
          provider
        }
      }
    }
  }
`;
