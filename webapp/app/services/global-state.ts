import {tracked} from '@glimmer/tracking';
import Service from '@ember/service';

export default class GlobalState extends Service {
  revision = null;
  mainColor = null;

  @tracked
  permissions = {};

  @tracked
  roles = [];

  @tracked
  documentFormats = [];

  isProjectNavigationListShowing = false;
}

declare module '@ember/service' {
  interface Registry {
    'global-state': GlobalState;
  }
}
