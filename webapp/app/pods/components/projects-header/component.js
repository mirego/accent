import {computed, observer} from '@ember/object';
import {run} from '@ember/runloop';
import {inject as service} from '@ember/service';
import Component from '@ember/component';

const DEBOUNCE_OFFSET = 500; // ms

// Attributes:
// session: Service <session>
export default Component.extend({
  tagName: 'header',
  session: service('session'),
  router: service('router'),
  globalState: service('global-state'),
  classNameBindings: ['project:withProject'],

  debouncedQuery: '',

  selectedRevision: computed(
    'globalState.revision',
    'project.revisions.[]',
    function() {
      const selected = this.globalState.revision;

      if (
        selected &&
        this.project.revisions.map(({id}) => id).includes(selected)
      ) {
        return selected;
      }

      if (!this.project.revisions) return;
      return this.project.revisions[0].id;
    }
  ),

  queryDidChanges: observer('debouncedQuery', function() {
    if (!this.debouncedQuery) return;
    run.debounce(this, this._debounceQuery, DEBOUNCE_OFFSET);
  }),

  _debounceQuery() {
    const query = this.debouncedQuery;
    this.set('debouncedQuery', '');
    const input = this.element.getElementsByTagName('input')[0];
    input && input.blur();

    this.router.transitionTo(
      'logged-in.project.revision.translations',
      this.project.id,
      this.selectedRevision,
      {
        queryParams: {query}
      }
    );
  },

  actions: {
    logout() {
      this.session.logout();
      window.location = '/';
    }
  }
});
