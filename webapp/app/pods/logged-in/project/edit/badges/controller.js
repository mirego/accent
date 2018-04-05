import {reads, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';

export default Controller.extend({
  project: reads('model.project'),
  emptyData: equal('model.project.name', undefined),
  showLoading: and('emptyData', 'model.loading')
});
