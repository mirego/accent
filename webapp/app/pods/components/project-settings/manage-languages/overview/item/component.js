import {inject as service} from '@ember/service';
import Component from '@ember/component';

// Attributes
// revision: Object <revision>
// permissions: Ember Object containing <permission>
// onPromoteMaster: Function
// onDelete: Function
export default Component.extend({
  i18n: service(),

  classNames: ['list-item'],
  classNameBindings: [
    'master:list-item--master',
    'isPromoting:list-item--promoting',
    'isDeleting:list-item--deleting',
    'deleted:list-item--deleted'
  ],

  isPromoting: false,
  isDeleting: false,
  isDeleted: false,

  actions: {
    promoteRevision() {
      /* eslint-disable no-alert */
      if (
        !window.confirm(
          this.i18n.t(
            'components.project_manage_languages_overview.promote_revision_master_confirm'
          )
        )
      ) {
        return;
      }
      /* eslint-enable no-alert */

      this.set('isPromoting', true);
      this.onPromoteMaster(this.revision).then(() =>
        this.set('isPromoting', false)
      );
    },

    deleteRevision() {
      /* eslint-disable no-alert */
      if (
        !window.confirm(
          this.i18n.t(
            'components.project_manage_languages_overview.delete_revision_confirm'
          )
        )
      )
        return;
      /* eslint-enable no-alert */

      this.set('isDeleting', true);
      this.onDelete(this.revision)
        .then(() => {
          this.setProperties({
            isDeleting: false,
            isDeleted: true
          });
        })
        .catch(() => this.set('isDeleting', false));
    }
  }
});
