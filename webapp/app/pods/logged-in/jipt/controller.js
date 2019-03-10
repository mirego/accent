/* eslint-disable no-magic-numbers */
import {inject as service} from '@ember/service';
import {observer, computed} from '@ember/object';
import Controller from '@ember/controller';
import {readOnly} from '@ember/object/computed';
import Color from 'npm:color';

export default Controller.extend({
  jipt: service('jipt'),
  router: service('router'),
  globalState: service('global-state'),

  queryParams: ['revisionId'],

  defaultColor: '#25ba7c',

  init() {
    window.addEventListener(
      'message',
      payload => {
        if (payload.data.jipt && payload.data.selectId) {
          this.router.transitionTo('logged-in.jipt.translation', payload.data.selectId);
        }
        if (payload.data.jipt && payload.data.selectIds) {
          this.router.transitionTo('logged-in.jipt.index', {queryParams: {translationIds: payload.data.selectIds}});
        }
      },
      false
    );
  },

  revision: readOnly('model.project.revision'),
  mainColor: readOnly('globalState.mainColor'),
  revisions: readOnly('model.project.revisions'),

  colors: computed('mainColor', function() {
    const color = Color(this.mainColor || this.defaultColor);

    return `
    --color-primary: ${color.string()};
    --color-primary-darken-10: ${color.darken(0.1).string()};
    --color-primary-opacity-10: ${color.fade(0.9).string()};
    --color-primary-opacity-70: ${color.fade(0.3).string()};
    --color-black: ${color
      .darken(0.7)
      .desaturate(0.3)
      .string()};
    `;
  }),

  translationsObserver: observer('model.project.revision.translations.entries', function() {
    if (!this.model.project) return;

    this.jipt.listTranslations(this.model.project.revision.translations.entries, this.model.project.revision);
  }),

  permissionsObserver: observer('model.permissions', function() {
    this.globalState.set('permissions', this.model.permissions);
  }),

  mainColorObserver: observer('model.project.mainColor', function() {
    if (!this.model.project) return;
    this.globalState.set('mainColor', this.model.project.mainColor);
  }),

  actions: {
    selectRevision(revisionId) {
      this.set('revisionId', revisionId);
    }
  }
});
