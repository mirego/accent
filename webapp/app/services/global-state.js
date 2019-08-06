import {computed} from '@ember/object';
import Service from '@ember/service';

export default Service.extend({
  revision: null,
  mainColor: null,

  permissions: computed({
    get() {
      return this._permissions ? this._permissions : {};
    },
    set(_key, value) {
      return (this._permissions = value);
    }
  }),

  roles: computed({
    get() {
      return this._roles ? this._roles : [];
    },
    set(_key, value) {
      return (this._roles = value);
    }
  }),

  documentFormats: computed({
    get() {
      return this._documentFormats ? this._documentFormats : [];
    },
    set(_key, value) {
      return (this._documentFormats = value);
    }
  }),

  isProjectNavigationListShowing: false
});
