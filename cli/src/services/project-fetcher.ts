// Vendor
import {error} from '@oclif/errors';
import fetch from 'node-fetch';

// Types
import {Config} from '../types/config';
import {Project} from '../types/project';

export default class ProjectFetcher {
  async fetch(config: Config): Promise<Project> {
    const response = await this.graphql(config);
    const data = await response.json();

    if (!data.data) {
      error(`Can not find the project for the key: ${config.apiKey}`);
    }

    return data.data && data.data.viewer.project;
  }

  private async graphql(config: Config) {
    const query = `query ProjectDetails($project_id: ID!) {
      viewer {
        project(id: $project_id) {
          id
          name
          lastSyncedAt

          masterRevision: revision {
            id
            name
            slug

            language {
              id
              name
              slug
            }
          }

          documents(pageSize: 1000) {
            meta {
              totalEntries
            }
            entries {
              id
              path
              format
            }
          }

          revisions {
            id
            isMaster
            translationsCount
            conflictsCount
            reviewedCount
            name
            slug
            language {
              id
              name
              slug
            }
          }
        }
      }
    }`;

    return await fetch(`${config.apiUrl}/graphql`, {
      body: JSON.stringify({query}),
      headers: {
        'Content-Type': 'application/json',
        authorization: `Bearer ${config.apiKey}`,
      },
      method: 'POST',
    });
  }
}
