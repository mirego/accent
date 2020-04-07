import {readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';

export default class BadgesController extends Controller {
  @readOnly('model.project')
  project: any;

  @equal('model.project.name', undefined)
  emptyData: boolean;

  @and('emptyData', 'model.loading')
  showLoading: boolean;
}
