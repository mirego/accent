import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import Component from '@ember/component';
const LOGOS = {
  DISCORD: 'assets/services/discord.svg',
  GITHUB: 'assets/services/github.svg',
  SLACK: 'assets/services/slack.svg'
};

// Attributes
// integration: Object <integration>
// onUpdate: Function
// onDelete: Function
export default Component.extend({
  intl: service('intl'),

  tagName: 'li',
  errors: [],

  isEditing: false,

  logoService: computed('integration.service', function() {
    return LOGOS[this.integration.service];
  }),

  mappedService: computed('integration.service', function() {
    return this.intl.t(
      `general.integration_services.${this.integration.service}`
    );
  }),

  actions: {
    toggleEdit() {
      this.set('errors', []);
      this.set('isEditing', !this.isEditing);
    },

    update(args) {
      this.onUpdate(args).then(({errors}) => {
        this.set('errors', errors);
        this.set('isEditing', errors && errors.length > 0);
      });
    },

    delete() {
      this.set('isDeleting', true);

      this.onDelete({id: this.integration.id}).then(({errors}) => {
        this.set('errors', errors);
        this.set('isEditing', errors && errors.length > 0);
      });
    }
  }
});
