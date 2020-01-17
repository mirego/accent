import gql from 'graphql-tag';

export interface ProjectQueryVariables {
  projectId: string;
}

export interface ProjectQueryResponse {
  roles: Array<{
    slug: string;
  }>;

  documentFormats: Array<{
    slug: string;
    name: string;
    extension: string;
  }>;

  viewer: {
    project: {
      id: string;
      name: string;
      mainColor: string;
      logo: string;

      viewerPermissions: string[];

      documents: {
        entries: Array<{
          id: string;
          path: string;
          format: string;
        }>;
      };

      revisions: Array<{
        id: string;
        name: string;
        isMaster: boolean;
        translationsCount: number;
        conflictsCount: number;

        language: {
          id: string;
          slug: string;
          name: string;
        };
      }>;
    };
  };
}

export default gql`
  query Project($projectId: ID!) {
    roles {
      slug
    }

    documentFormats {
      slug
      name
      extension
    }

    viewer {
      project(id: $projectId) {
        id
        name
        mainColor
        logo

        viewerPermissions

        documents {
          entries {
            id
            path
            format
          }
        }

        revisions {
          id
          name
          isMaster
          translationsCount
          conflictsCount

          language {
            id
            slug
            name
          }
        }
      }
    }
  }
`;
