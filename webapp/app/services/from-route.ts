import Service from '@ember/service';
import {inject as service} from '@ember/service';
import RouterService from '@ember/routing/router-service';

export default class FromRoute extends Service {
  @service('router')
  router: RouterService;

  transitionTo(from: any | null, current: string, ...fallback: any[]) {
    if (from && from.name && !from.name.startsWith(current)) {
      this.router.transitionTo(
        from.name,
        ...Object.values(from.parent.params as object)
      );
    } else {
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore
      this.router.transitionTo(...fallback);
    }
  }
}

declare module '@ember/service' {
  interface Registry {
    'from-route': FromRoute;
  }
}
