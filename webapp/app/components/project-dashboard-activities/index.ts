import Component from '@glimmer/component';
import {service} from '@ember/service';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';
import {gql} from '@apollo/client/core';
import Apollo from 'accent-webapp/services/apollo';
import {schedule} from '@ember/runloop';

const projectDashboardActivitiesQuery = gql`
  query ProjectDashboardActivities($projectId: ID!) {
    viewer {
      project(id: $projectId) {
        id

        activities(pageSize: 7) {
          entries {
            id
            action
            insertedAt
            updatedAt
            isBatch
            isRollbacked
            activityType
            text

            stats {
              action
              count
            }

            user {
              id
              pictureUrl
              fullname
              isBot
            }

            document {
              id
              path
            }

            translation {
              id
              key
              correctedText
              isRemoved
            }

            revision {
              id
              name
              language {
                id
                name
              }
            }

            version {
              id
              tag
            }

            batchedOperations {
              id

              document {
                id
                path
              }
            }

            rollbackedOperation {
              id
              action
              text

              user {
                id
                fullname
                isBot
              }

              translation {
                id
                key
              }

              document {
                id
                path
              }
            }
          }
        }
      }
    }
  }
`;

interface Activity {
  id: string;
  action: string;
  insertedAt: string;
  updatedAt: string;
  isBatch: boolean;
  isRollbacked: boolean;
  activityType: string;
  text: string;
  stats: {
    action: string;
    count: number;
  };
  user: {
    id: string;
    pictureUrl: string;
    fullname: string;
    isBot: boolean;
  };
  document: {
    id: string;
    path: string;
  };
  translation: {
    id: string;
    key: string;
    correctedText: string;
    isRemoved: boolean;
  };
  revision: {
    id: string;
    name: string;
    language: {
      id: string;
      name: string;
    };
  };
  version: {
    id: string;
    tag: string;
  };
  batchedOperations: Array<{
    id: string;
    document: {
      id: string;
      path: string;
    };
  }>;
  rollbackedOperation: {
    id: string;
    action: string;
    text: string;
    user: {
      id: string;
      fullname: string;
      isBot: boolean;
    };
    translation: {
      id: string;
      key: string;
    };
    document: {
      id: string;
      path: string;
    };
  };
}

interface Args {
  projectId: string;
  permissions: Record<string, true>;
  project: {id: string};
}

interface ProjectDashboardActivitiesData {
  viewer: {
    project: {
      id: string;
      activities: {
        entries: Activity[];
      };
    };
  };
}

export default class ProjectDashboardActivitiesComponent extends Component<Args> {
  @service('apollo')
  declare apollo: Apollo;

  @tracked
  activities: Activity[] = [];

  @tracked
  loading = true;

  constructor(owner: unknown, args: Args) {
    super(owner, args);
    schedule('afterRender', this, this.fetchActivities);
  }

  @action
  async fetchActivities() {
    try {
      const cachedResult =
        this.apollo.client.readQuery<ProjectDashboardActivitiesData>({
          query: projectDashboardActivitiesQuery,
          variables: {projectId: this.args.projectId}
        });

      if (cachedResult?.viewer?.project?.activities?.entries) {
        this.activities = cachedResult.viewer.project.activities.entries;
        this.loading = false;
      }

      const result =
        await this.apollo.client.query<ProjectDashboardActivitiesData>({
          query: projectDashboardActivitiesQuery,
          variables: {projectId: this.args.projectId},
          fetchPolicy: 'network-only'
        });

      this.activities = result.data.viewer.project.activities.entries;
    } catch (_error) {
      if (this.loading) {
        this.activities = [];
      }
    } finally {
      this.loading = false;
    }
  }
}
