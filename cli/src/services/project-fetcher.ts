// Vendor
import {error} from '@oclif/errors'
import fetch from 'node-fetch'

// Types
import {Config} from '../types/config'
import {Project} from '../types/project'

export default class ProjectFetcher {
  public async fetch(config: Config): Promise<Project> {
    const response = await this.graphql(config)
    const data = await response.json()

    if (!data.data) {
      error(`Can not find the project for the key: ${config.apiKey}`)
    }

    return data.data && data.data.viewer.project
  }

  private graphql(config: Config) {
    const query = `query ProjectDetails($project_id: ID!) {
      viewer {
        project(id: $project_id) {
          id
          name
          lastSyncedAt

          language {
            id
            name
            slug
          }
          documents {
            entries {
              id
              path
              format
            }
          }
          revisions {
            id
            translationsCount
            conflictsCount
            reviewedCount
            language {
              id
              name
              slug
            }
          }
        }
      }
    }`

    return fetch(`${config.apiUrl}/graphql`, {
      body: JSON.stringify({query}),
      headers: {
        'Content-Type': 'application/json',
        authorization: `Bearer ${config.apiKey}`
      },
      method: 'POST'
    })
  }
}
