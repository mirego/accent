import Service from '@ember/service';
import Transition from '@ember/routing/-private/transition';

export default class RouteParams extends Service {
  fetch(transition: Transition) {
    return transition.to.params;
  }
}

declare module '@ember/service' {
  interface Registry {
    'route-params': RouteParams;
  }
}
