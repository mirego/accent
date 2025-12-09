import Component from '@glimmer/component';
import {service} from '@ember/service';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';
import {gql} from '@apollo/client/core';
import Apollo from 'accent-webapp/services/apollo';
import {schedule} from '@ember/runloop';

const projectLastActivitySyncQuery = gql`
  query ProjectLastActivitySync($projectId: ID!) {
    viewer {
      project(id: $projectId) {
        id
        lastActivitySync: lastActivity(action: "sync") {
          id
          action
          insertedAt
        }
      }
    }
  }
`;

interface Args {
  projectId: string;
}

interface ProjectLastActivitySyncData {
  viewer: {
    project: {
      id: string;
      lastActivitySync: {
        id: string;
        action: string;
        insertedAt: string;
      } | null;
    };
  };
}

export default class ProjectLastActivitySyncComponent extends Component<Args> {
  @service('apollo')
  declare apollo: Apollo;

  @tracked
  lastActivitySync: {
    id: string;
    action: string;
    insertedAt: string;
  } | null = null;

  @tracked
  loading = true;

  constructor(owner: unknown, args: Args) {
    super(owner, args);
    schedule('afterRender', this, this.fetchLastActivitySync);
  }

  @action
  async fetchLastActivitySync() {
    try {
      const result =
        await this.apollo.client.query<ProjectLastActivitySyncData>({
          query: projectLastActivitySyncQuery,
          variables: {projectId: this.args.projectId},
          fetchPolicy: 'network-only'
        });

      this.lastActivitySync = result.data.viewer.project.lastActivitySync;
    } catch (_error) {
      this.lastActivitySync = null;
    } finally {
      this.loading = false;
    }
  }
}
