import {gql} from '@apollo/client/core';

export interface ProjectDashboardQueryVariables {
  projectId: string;
  documentId?: string | null;
  versionId?: string | null;
}

export interface ProjectDashboardQueryResponse {
  viewer: {
    project: {
      id: string;
      name: string;
      lastSyncedAt: string;

      documents: {
        entries: Array<{
          id: string;
          path: string;
        }>;
      };

      versions: {
        entries: Array<{
          id: string;
          tag: string;
        }>;
      };

      revisions: Array<{
        id: string;
        conflictsCount: number;
        reviewedCount: number;
        translatedCount: number;
        translationsCount: number;
        isMaster: boolean;
        name: string;
        language: {
          id: string;
          name: string;
        };
      }>;
    };
  };
}

export default gql`
  query Dashboard($projectId: ID!, $documentId: ID, $versionId: ID) {
    viewer {
      project(id: $projectId) {
        id
        name
        lastSyncedAt

        documents {
          entries {
            id
            path
          }
        }

        versions {
          entries {
            id
            tag
          }
        }

        revisions(documentId: $documentId, versionId: $versionId) {
          id
          conflictsCount
          reviewedCount
          translatedCount
          translationsCount
          isMaster
          name
          rtl
          language {
            id
            name
            rtl
          }
        }
      }
    }
  }
`;
