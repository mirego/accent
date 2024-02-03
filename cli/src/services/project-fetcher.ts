// Vendor
import {CLIError} from '@oclif/errors';
import * as chalk from 'chalk';
import fetch from 'node-fetch';

// Types
import {Config} from '../types/config';
import {ProjectViewer} from '../types/project';

export default class ProjectFetcher {
  async fetch(config: Config, params?: object): Promise<ProjectViewer> {
    const response = await this.graphql(config, params || {});
    try {
      const data = (await response.json()) as {data: any};

      if (!data.data) {
        throw new CLIError(
          chalk.red(`Can’t find the project for the key: ${config.apiKey}`),
          {exit: 1}
        );
      }

      return data.data && data.data.viewer;
    } catch (_) {
      throw new CLIError(
        chalk.red(
          `Can’t fetch the project on ${config.apiUrl} with key ${config.apiKey}`
        ),
        {exit: 1}
      );
    }
  }

  private async graphql(config: Config, params: object) {
    const query = `query ProjectDetails($project_id: ID! $versionId: ID) {
      viewer {
        user {
          fullname
        }

        project(id: $project_id) {
          id
          name
          logo
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

          collaborators {
            ... on ConfirmedCollaborator {
              id
              role
              user {
                email
                fullname
              }
            }
          }

          versions(pageSize: 1000) {
            meta {
              totalEntries
            }
            entries {
              name
              tag
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

          revisions(versionId: $versionId) {
            id
            isMaster
            translatedCount
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

    // eslint-disable-next-line camelcase
    const configParams = config.project ? {project_id: config.project} : {};
    const variables = {...configParams, ...params};

    return await fetch(`${config.apiUrl}/graphql`, {
      body: JSON.stringify({query, variables}),
      headers: {
        'Content-Type': 'application/json',
        authorization: `Bearer ${config.apiKey}`,
      },
      method: 'POST',
    });
  }
}
