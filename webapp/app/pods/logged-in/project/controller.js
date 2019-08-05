/* eslint-disable no-magic-numbers */
import {observer, computed} from '@ember/object';
import {inject as service} from '@ember/service';
import {reads, readOnly, not, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import Color from 'color';

export default Controller.extend({
  session: service(),
  globalState: service('global-state'),

  defaultColor: '#25ba7c',

  project: reads('model.project'),
  mainColor: reads('globalState.mainColor'),
  revisions: reads('project.revisions'),
  permissions: readOnly('globalState.permissions'),
  noProject: not('project'),
  notLoading: not('model.loading'),
  showError: and('noProject', 'notLoading'),

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

  permissionsObserver: observer('model.permissions', function() {
    this.globalState.set('permissions', this.model.permissions);
  }),

  mainColorObserver: observer('model.project.mainColor', function() {
    if (!this.model.project) return;
    this.globalState.set('mainColor', this.model.project.mainColor);
  }),

  rolesObserver: observer('model.roles', function() {
    this.globalState.set('roles', this.model.roles);
  }),

  documentFormatsObserver: observer('model.documentFormats', function() {
    this.globalState.set('documentFormats', this.model.documentFormats);
  })
});
