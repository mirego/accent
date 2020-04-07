import Service, {inject as service} from '@ember/service';
import Apollo from 'accent-webapp/services/apollo';
import {tracked} from '@glimmer/tracking';
import {setProperties} from '@ember/object';

interface GraphQLOptions {
  options?: any;
  props?: (data: any) => any;
}

export class Subscription {
  apollo: Apollo;

  @tracked
  queryObservable: any;

  @tracked
  querySubscription: any;

  props: undefined | ((data: any) => any);

  constructor(
    apollo: Apollo,
    model: any,
    query: any,
    options?: any,
    props?: (data: any) => any
  ) {
    this.apollo = apollo;
    this.queryObservable = this.createQuery(query, options);
    this.querySubscription = this.createSubscription(model);
    this.props = props || ((data) => data);
  }

  currentResult() {
    const queryObservable = this.queryObservable;
    const result = queryObservable.currentResult();
    const mappedResult = this.mapResult(result, this.props);

    return mappedResult;
  }

  clearSubscription() {
    const subscription = this.querySubscription;

    if (subscription) subscription.unsubscribe();
  }

  private createQuery(query: any, options = {}) {
    this.clearSubscription();

    return this.apollo.client.watchQuery({
      query,
      ...options,
    });
  }

  private createSubscription(graphqlObject: () => any) {
    const next = (result: any) => {
      const object = graphqlObject();

      if (!object) return;

      const mappedResult = this.mapResult(result, this.props);

      setProperties(object, mappedResult);
    };

    return this.queryObservable.subscribe({next});
  }

  private mapResult(result: any, props: any) {
    if (result.data && Object.keys(result.data).length) {
      const data = props(result.data);

      return {
        ...data,
        loading: result.loading,
        refetch: this.queryObservable.refetch,
        fetchMore: this.queryObservable.fetchMore,
        startPolling: this.queryObservable.startPolling,
        stopPolling: this.queryObservable.stopPolling,
      };
    } else {
      return result;
    }
  }
}

export default class ApolloSubscription extends Service {
  @service('apollo')
  apollo: Apollo;

  graphql(model: any, query: any, {options, props}: GraphQLOptions) {
    props = props || ((data: any) => data);

    return new Subscription(this.apollo, model, query, options, props);
  }

  clearSubscription(subscription: Subscription) {
    if (subscription) subscription.clearSubscription();
  }
}

declare module '@ember/service' {
  interface Registry {
    'apollo-subscription': ApolloSubscription;
  }
}
