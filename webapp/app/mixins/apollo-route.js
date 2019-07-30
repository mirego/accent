import {inject as service} from '@ember/service';
import Mixin from '@ember/object/mixin';
import EmberObject, {setProperties} from '@ember/object';

const PROPS_FN = data => data;

export default Mixin.create({
  apollo: service('apollo'),

  graphql(query, {options, props}) {
    props = props || PROPS_FN;
    const graphqlObject = () => this.modelFor(this.routeName);

    this._createQuery(query, options);
    this._createSubscription(props, graphqlObject);

    return this._currentResult(props);
  },

  deactivate() {
    this._super(...arguments);

    this._clearSubscription();
  },

  _currentResult(props) {
    const queryObservable = this.queryObservable;
    const result = queryObservable.currentResult();
    const mappedResult = this._mapResult(result, props);

    return EmberObject.create(mappedResult);
  },

  _createQuery(query, options = {}) {
    this._clearSubscription();

    const queryObservable = this.apollo.client.watchQuery({
      query,
      ...options
    });
    setProperties(this, {queryObservable});
  },

  _createSubscription(props, graphqlObject) {
    const next = result => {
      const o = graphqlObject();
      if (!o) return;

      const mappedResult = this._mapResult(result, props);
      setProperties(o, mappedResult);
    };

    const querySubscription = this.queryObservable.subscribe({next});
    setProperties(this, {querySubscription});
  },

  _clearSubscription() {
    const subscription = this.querySubscription;
    if (subscription) subscription.unsubscribe();
  },

  _mapResult(result, props) {
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
});
