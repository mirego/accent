import {tracked} from '@glimmer/tracking';
import Service from '@ember/service';

export default class GlobalState extends Service {
  @tracked
  revision: any | null = null;

  @tracked
  mainColor: string | null = null;

  @tracked
  permissions: Record<string, boolean> = {};

  @tracked
  roles: Array<{slug: string}> = [];

  @tracked
  documentFormats: Array<{slug: string; name: string; extension: string}> = [];

  @tracked
  isProjectNavigationListShowing = false;
}

declare module '@ember/service' {
  interface Registry {
    'global-state': GlobalState;
  }
}
