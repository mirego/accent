import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import Component from '@ember/component';
const LOGOS = {
  SLACK: 'assets/services/slack.svg',
  DISCORD: 'assets/services/discord.svg'
};

// Attributes
// integration: Object <integration>
// onUpdate: Function
// onDelete: Function
export default Component.extend({
  i18n: service(),

  tagName: 'li',

  isEditing: false,

  logoService: computed('integration.service', function() {
    return LOGOS[this.integration.service];
  }),

  mappedService: computed('integration.service', function() {
    return this.i18n.t(
      `general.integration_services.${this.integration.service}`
    );
  }),

  actions: {
    toggleEdit() {
      this.set('isEditing', !this.isEditing);
    },

    update(args) {
      return this.onUpdate(args).then(() => this.set('isEditing', false));
    },

    delete() {
      this.set('isDeleting', true);

      this.onDelete({id: this.integration.id}).then(() =>
        this.set('isDeleting', false)
      );
    }
  }
});
