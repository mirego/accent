import Component from '@ember/component';

// Attributes
// project: Object <project>
// permissions: Ember Object containing <permission>
// integration: Array of <integration>
// onCreateIntegration: Function
// onUpdateIntegration: Function
// onDeleteIntegration: Function
export default Component.extend({
  showCreateForm: false,

  actions: {
    toggleCreateForm() {
      this.set('showCreateForm', !this.showCreateForm);
    },

    create(args) {
      return this.onCreateIntegration(args).then(({errors}) => {
        this.set('showCreateForm', errors && errors.length > 0);
        return {errors};
      });
    }
  }
});
