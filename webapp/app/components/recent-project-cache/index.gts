import Component from '@glimmer/component';
import {service} from '@ember/service';
import {timeout, dropTask} from 'ember-concurrency';
import RecentProjects from 'accent-webapp/services/recent-projects';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import perform from 'ember-concurrency/helpers/perform';

interface Args {
  project: {id: string};
}

const DEBOUNCE_ADD = 1000; // ms

export default class RecentProjectCache extends Component<Args> {
  <template>
    <div {{didInsert (perform this.persistRecentProject)}}></div>
  </template>
  @service('recent-projects')
  declare recentProjects: RecentProjects;

  persistRecentProject = dropTask(async () => {
    await timeout(DEBOUNCE_ADD);
    this.recentProjects.add(this.args.project.id);
  });
}
