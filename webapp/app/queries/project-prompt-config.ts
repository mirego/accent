import gql from 'graphql-tag';

export interface ProjectPromptConfigResponse {
  viewer: {
    project: {
      id: string;
      prompts: Array<{
        id: string;
        name: string | null;
        displayName: string;
        content: string;
        quickAccess: string | null;
      }>;
    };
  };
}

export default gql`
  query ProjectPromptConfig($projectId: ID!) {
    viewer {
      project(id: $projectId) {
        id

        prompts {
          id
          name
          displayName
          content
          quickAccess
        }

        promptConfig {
          provider
        }
      }
    }
  }
`;
