import {action} from '@ember/object';
import {equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import {tracked} from '@glimmer/tracking';

export default class CommentsController extends Controller {
  queryParams = ['page'];

  @tracked
  page: number | null = 1;

  @equal('model.comments.entries', undefined)
  emptyEntries: boolean;

  @and('emptyEntries', 'model.loading')
  showSkeleton: boolean;

  @action
  selectPage(page: number) {
    window.scroll(0, 0);

    this.page = page;
  }
}
