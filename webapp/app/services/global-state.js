import {computed} from '@ember/object';
import Service from '@ember/service';

export default Service.extend({
  revision: null,
  mainColor: null,

  permissions: computed(() => ({})),
  roles: computed(() => []),
  documentFormats: computed(() => []),

  isProjectNavigationListShowing: false
});
