import {inject as service} from '@ember/service';
import {observer, computed} from '@ember/object';
import {reads} from '@ember/object/computed';
import Component from '@ember/component';

// Attributes
// project: Object <project>
// permissions: Ember Object containing <permission>
// onUpdateProject: Function
export default Component.extend({
  globalState: service('global-state'),
  flashMessages: service(),
  intl: service('intl'),

  name: reads('project.name'),
  mainColor: reads('project.mainColor'),
  logo: reads('project.logo'),
  isFileOperationsLocked: reads('project.isFileOperationsLocked'),

  mainColorPreviewObserver: observer('mainColor', function() {
    this.globalState.set('mainColor', this.mainColor);
  }),

  unchangedForm: computed('project', 'mainColor', 'name', 'logo', function() {
    return (
      this.logo === this.project.logo &&
      this.mainColor === this.project.mainColor &&
      this.name === this.project.name
    );
  }),

  actions: {
    logoPicked(logo) {
      this.set('logo', logo);
    },

    setLockedFileOperations() {
      this.toggleProperty('isFileOperationsLocked');
      this.onUpdateProject(
        this.getProperties(
          'isFileOperationsLocked',
          'name',
          'mainColor',
          'logo'
        )
      );
    },

    updateProject() {
      this.onUpdateProject(
        this.getProperties(
          'isFileOperationsLocked',
          'name',
          'mainColor',
          'logo'
        )
      );
    },

    logoReset() {
      this.set('logo', null);
    },

    logoChange([logo]) {
      if (!logo) return;

      if (logo.type !== 'image/svg+xml') {
        this.flashMessages.error(
          this.intl.t('components.project_settings.form.unsupported_logo_type')
        );

        return;
      }

      const reader = new FileReader();

      reader.onload = logoProcessed =>
        this.set('logo', logoProcessed.target.result);
      reader.readAsText(logo);
    }
  }
});
