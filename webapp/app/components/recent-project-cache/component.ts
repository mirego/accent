import Component from '@glimmer/component';
import {inject as service} from '@ember/service';
import {timeout, dropTask} from 'ember-concurrency';

import RecentProjects from 'accent-webapp/services/recent-projects';

interface Args {
  project: {id: string};
}

const DEBOUNCE_ADD = 1000; // ms

export default class RecentProjectCache extends Component<Args> {
  @service('recent-projects')
  recentProjects: RecentProjects;

  persistRecentProject = dropTask(async () => {
    await timeout(DEBOUNCE_ADD);
    this.recentProjects.add(this.args.project.id);
  });
}
