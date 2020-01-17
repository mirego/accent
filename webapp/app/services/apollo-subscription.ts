import Service, {inject as service} from '@ember/service';
import Apollo from 'accent-webapp/services/apollo';
import {tracked} from '@glimmer/tracking';
import {setProperties} from '@ember/object';

interface GraphQLOptions {
  options?: any;
  props?: (data: any) => any;
}

export default class ApolloSubscription extends Service {
  @service('apollo')
  apollo: Apollo;

  @tracked
  queryObservable: any = null;

  @tracked
  querySubscription: any = null;

  graphql(model: any, query: any, {options, props}: GraphQLOptions) {
    props = props || ((data: any) => data);

    this.createQuery(query, options);
    this.createSubscription(props, model);

    return this.currentResult(props);
  }

  clearSubscription() {
    const subscription = this.querySubscription;

    if (subscription) subscription.unsubscribe();
  }

  private currentResult(props: any) {
    const queryObservable = this.queryObservable;
    const result = queryObservable.currentResult();
    const mappedResult = this.mapResult(result, props);

    return mappedResult;
  }

  private createQuery(query: any, options = {}) {
    this.clearSubscription();

    const queryObservable = this.apollo.client.watchQuery({
      query,
      ...options
    });

    this.queryObservable = queryObservable;
  }

  private createSubscription(props: any, graphqlObject: () => any) {
    const next = (result: any) => {
      const object = graphqlObject();

      if (!object) return;

      const mappedResult = this.mapResult(result, props);

      setProperties(object, mappedResult);
    };

    const querySubscription = this.queryObservable.subscribe({next});

    this.querySubscription = querySubscription;
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
        stopPolling: this.queryObservable.stopPolling
      };
    } else {
      return result;
    }
  }
}

declare module '@ember/service' {
  interface Registry {
    'apollo-subscription': ApolloSubscription;
  }
}
