import Component from '@ember/component';

// Attributes
// project: Object <project>
// onSubmit: Function
export default Component.extend({
  actions: {
    deleteProject() {
      this.onSubmit();
    }
  }
});
