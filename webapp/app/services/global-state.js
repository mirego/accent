import {computed} from '@ember/object';
import Service from '@ember/service';

export default Service.extend({
  selectedRevision: null,

  permissions: computed(() => ({})),
  roles: computed(() => []),
  documentFormats: computed(() => []),

  isProjectNavigationListShowing: false
});
