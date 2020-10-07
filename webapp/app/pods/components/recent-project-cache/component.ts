import Component from '@glimmer/component';
import {inject as service} from '@ember/service';
import {dropTask} from 'ember-concurrency-decorators';

import RecentProjects from 'accent-webapp/services/recent-projects';

interface Args {
  project: {id: string};
}

export default class RecentProjectCache extends Component<Args> {
  @service('recent-projects')
  recentProjects: RecentProjects;

  @dropTask
  *persistRecentProject() {
    this.recentProjects.add(this.args.project.id);
  }
}
