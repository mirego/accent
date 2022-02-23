import Service from '@ember/service';

export default class RouteParams extends Service {
  fetch(transition: any, routeName: string) {
    return transition.routeInfos.find((route: any) => route.name === routeName)
      .params;
  }
}

declare module '@ember/service' {
  interface Registry {
    'route-params': RouteParams;
  }
}
