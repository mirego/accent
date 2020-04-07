import Service from '@ember/service';
import Transition from '@ember/routing/-private/transition';

export default class RouteParams extends Service {
  fetch(transition: Transition, routeName: string) {
    // eslint-disable-next-line @typescript-eslint/ban-ts-ignore
    // @ts-ignore
    return transition.routeInfos.find((route) => route.name === routeName)
      .params;
  }
}

declare module '@ember/service' {
  interface Registry {
    'route-params': RouteParams;
  }
}
