// Vendor
import {CLIError} from '@oclif/errors';
import chalk from 'chalk';
import fetch from 'node-fetch';

// Types
import {Config} from '../types/config';
import {Project} from '../types/project';

export default class ProjectFetcher {
  async fetch(config: Config): Promise<Project> {
    const response = await this.graphql(config);
    try {
      const data = await response.json();

      if (!data.data) {
        throw new CLIError(
          chalk.red(`Can not find the project for the key: ${config.apiKey}`),
          {exit: 1}
        );
      }

      return data.data && data.data.viewer.project;
    } catch (_) {
      throw new CLIError(
        chalk.red(`Can not fetch the project on ${config.apiUrl}`),
        {exit: 1}
      );
    }
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
