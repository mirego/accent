import Service from '@ember/service';

export default Service.extend({
  fetch(transition, routeName) {
    return transition.routeInfos.find((route) => route.name === routeName).params;
  }
});
